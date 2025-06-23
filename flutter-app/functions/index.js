const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialiser Firebase Admin SDK
admin.initializeApp();

const db = admin.firestore();

/**
 * Cloud Function déclenchée lors de la création d'un compte utilisateur
 * Crée automatiquement un document de base dans la collection 'users'
 */
exports.createUserDocument = functions.auth.user().onCreate(async (user) => {
  try {
    console.log(`Création du document utilisateur pour: ${user.uid}`);
    
    // Créer un document de base avec les informations essentielles
    const userDoc = {
      personalInfo: {
        email: user.email,
        name: user.displayName || '',
        profilePictureUrl: user.photoURL || null,
        dateOfBirth: null,
      },
      menopauseInfo: {
        phase: null,
        symptoms: [],
      },
      cycleInfo: {
        lastPeriodStartDate: null,
        averageCycleLength: null,
        averagePeriodLength: null,
        estimatedByAI: false,
        completedCycles: 0,
      },
      wellnessConcerns: [],
      onboarding: {
        currentStep: 'welcome',
        completed: false,
        selectedGoals: [],
      },
      preferences: {
        notificationsEnabled: true,
        anonymousModeEnabled: false,
        language: 'fr', // Par défaut en français
        timezone: null,
      },
      metadata: {
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        firebaseAuthCreatedAt: user.metadata.creationTime,
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      // Informations de sécurité et audit
      security: {
        emailVerified: user.emailVerified,
        providerData: user.providerData.map(provider => ({
          providerId: provider.providerId,
          uid: provider.uid,
        })),
      },
    };

    // Sauvegarder dans Firestore
    await db.collection('users').doc(user.uid).set(userDoc);
    
    console.log(`Document utilisateur créé avec succès pour: ${user.uid}`);
    
    // Créer des index pour les requêtes fréquentes
    await _createUserIndexes(user.uid, userDoc);
    
    return { success: true, userId: user.uid };
    
  } catch (error) {
    console.error(`Erreur lors de la création du document utilisateur pour ${user.uid}:`, error);
    throw new functions.https.HttpsError('internal', 'Erreur lors de la création du profil utilisateur');
  }
});

/**
 * Créer des index pour optimiser les requêtes
 */
async function _createUserIndexes(userId, userDoc) {
  try {
    // Index pour les symptômes (pour les recommandations)
    await db.collection('user_symptoms').doc(userId).set({
      symptoms: userDoc.menopauseInfo.symptoms,
      menopausePhase: userDoc.menopauseInfo.phase,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Index pour les préoccupations (pour le contenu personnalisé)
    await db.collection('user_concerns').doc(userId).set({
      concerns: userDoc.wellnessConcerns,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Index pour les statistiques anonymisées (pour la recherche)
    await _updateAnalytics(userDoc);
    
  } catch (error) {
    console.error(`Erreur lors de la création des index pour ${userId}:`, error);
    // Ne pas faire échouer la fonction principale si les index échouent
  }
}

/**
 * Mettre à jour les statistiques anonymisées
 */
async function _updateAnalytics(userDoc) {
  try {
    const analyticsRef = db.collection('analytics').doc('user_stats');
    
    await db.runTransaction(async (transaction) => {
      const analyticsDoc = await transaction.get(analyticsRef);
      
      if (analyticsDoc.exists) {
        const data = analyticsDoc.data();
        transaction.update(analyticsRef, {
          totalUsers: admin.firestore.FieldValue.increment(1),
          usersByPhase: {
            ...data.usersByPhase,
            [userDoc.menopauseInfo.phase || 'unknown']: 
              (data.usersByPhase?.[userDoc.menopauseInfo.phase || 'unknown'] || 0) + 1
          },
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(analyticsRef, {
          totalUsers: 1,
          usersByPhase: {
            [userDoc.menopauseInfo.phase || 'unknown']: 1
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour des statistiques:', error);
  }
}

/**
 * Cloud Function pour nettoyer les données utilisateur lors de la suppression du compte
 */
exports.cleanupUserData = functions.auth.user().onDelete(async (user) => {
  try {
    console.log(`Nettoyage des données pour l'utilisateur: ${user.uid}`);
    
    const batch = db.batch();
    
    // Supprimer le document utilisateur principal
    batch.delete(db.collection('users').doc(user.uid));
    
    // Supprimer les index
    batch.delete(db.collection('user_symptoms').doc(user.uid));
    batch.delete(db.collection('user_concerns').doc(user.uid));
    
    // Supprimer les cycles
    const cyclesSnapshot = await db.collection('cycles')
      .where('userId', '==', user.uid)
      .get();
    
    cyclesSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    // Supprimer les symptômes quotidiens
    const symptomsSnapshot = await db.collection('daily_symptoms')
      .where('userId', '==', user.uid)
      .get();
    
    symptomsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    // Supprimer les conversations IA
    const conversationsSnapshot = await db.collection('ai_conversations')
      .where('userId', '==', user.uid)
      .get();
    
    conversationsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    // Supprimer les journaux
    const journalsSnapshot = await db.collection('journals')
      .where('userId', '==', user.uid)
      .get();
    
    journalsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    // Exécuter le batch
    await batch.commit();
    
    console.log(`Nettoyage terminé pour l'utilisateur: ${user.uid}`);
    
    return { success: true, userId: user.uid };
    
  } catch (error) {
    console.error(`Erreur lors du nettoyage des données pour ${user.uid}:`, error);
    throw new functions.https.HttpsError('internal', 'Erreur lors du nettoyage des données utilisateur');
  }
});

/**
 * Cloud Function pour mettre à jour les statistiques lors de la modification du profil
 */
exports.updateUserStats = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      const userId = context.params.userId;
      
      // Vérifier si la phase de ménopause a changé
      if (before.menopauseInfo?.phase !== after.menopauseInfo?.phase) {
        await _updatePhaseStatistics(before.menopauseInfo?.phase, after.menopauseInfo?.phase);
      }
      
      // Mettre à jour les index si nécessaire
      if (JSON.stringify(before.menopauseInfo?.symptoms) !== JSON.stringify(after.menopauseInfo?.symptoms)) {
        await db.collection('user_symptoms').doc(userId).update({
          symptoms: after.menopauseInfo?.symptoms || [],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
      if (JSON.stringify(before.wellnessConcerns) !== JSON.stringify(after.wellnessConcerns)) {
        await db.collection('user_concerns').doc(userId).update({
          concerns: after.wellnessConcerns || [],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
    } catch (error) {
      console.error(`Erreur lors de la mise à jour des statistiques pour ${context.params.userId}:`, error);
    }
  });

/**
 * Mettre à jour les statistiques de phase
 */
async function _updatePhaseStatistics(oldPhase, newPhase) {
  try {
    const analyticsRef = db.collection('analytics').doc('user_stats');
    
    await db.runTransaction(async (transaction) => {
      const analyticsDoc = await transaction.get(analyticsRef);
      
      if (analyticsDoc.exists) {
        const data = analyticsDoc.data();
        const updates = {
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        };
        
        // Décrémenter l'ancienne phase
        if (oldPhase) {
          updates[`usersByPhase.${oldPhase}`] = admin.firestore.FieldValue.increment(-1);
        }
        
        // Incrémenter la nouvelle phase
        if (newPhase) {
          updates[`usersByPhase.${newPhase}`] = admin.firestore.FieldValue.increment(1);
        }
        
        transaction.update(analyticsRef, updates);
      }
    });
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour des statistiques de phase:', error);
  }
} 