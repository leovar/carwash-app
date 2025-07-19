
const functions = require('firebase-functions/v2');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// Configuración común para todas las funciones
const functionConfig = {
  timeoutSeconds: 540,
  memory: '1GiB',
  maxInstances: 10,
  region: 'us-central1' // o tu región preferida
};

// Función para actualizar todos los customers con companyId
exports.updateCustomersCompanyId = functions.https.onCall(functionConfig, async (request) => {
  try {
    console.log('Iniciando actualización masiva de customers...');

    const data = request.data;
    const companyId = data.companyId || 'gtixUTsEImKUuhdSCwKX';
    const batchSize = 450; // Límite seguro para Firestore batch

    let totalUpdated = 0;
    let totalProcessed = 0;
    let hasMoreDocuments = true;
    let lastDocumentId = null;

    while (hasMoreDocuments) {
      try {
        // Construir la consulta
        let query = db.collection('invoices').limit(batchSize);

        // Si tenemos un último documento, empezar después de él
        if (lastDocumentId) {
          const lastDoc = await db.collection('invoices').doc(lastDocumentId).get();
          if (lastDoc.exists) {
            query = query.startAfter(lastDoc);
          }
        }

        // Obtener el lote de documentos
        const snapshot = await query.get();

        if (snapshot.empty) {
          hasMoreDocuments = false;
          break;
        }

        // Crear batch para actualizar
        const batch = db.batch();
        let updatedInBatch = 0;

        // Procesar cada documento
        snapshot.forEach(doc => {
          const data = doc.data();

          // Verificar si el documento necesita actualización
          if (!data.hasOwnProperty('companyId') || data.companyId === null) {
            batch.update(doc.ref, { companyId: companyId });
            updatedInBatch++;
          }

          // Guardar el ID del último documento para paginación
          lastDocumentId = doc.id;
        });

        // Ejecutar el batch solo si hay documentos para actualizar
        if (updatedInBatch > 0) {
          await batch.commit();
          console.log(`Batch completado: ${updatedInBatch} documentos actualizados`);
        }

        totalUpdated += updatedInBatch;
        totalProcessed += snapshot.size;

        // Log de progreso
        console.log(`Progreso: ${totalProcessed} procesados, ${totalUpdated} actualizados`);

        // Si obtuvimos menos documentos que el límite, no hay más
        if (snapshot.size < batchSize) {
          hasMoreDocuments = false;
        }

        // Pequeña pausa para evitar límites de rate
        await new Promise(resolve => setTimeout(resolve, 100));

      } catch (batchError) {
        console.error('Error en batch:', batchError);
        // Continuar con el siguiente batch en caso de error
        continue;
      }
    }

    console.log(`Actualización completada. Total: ${totalUpdated} de ${totalProcessed} documentos actualizados`);

    return {
      success: true,
      totalProcessed: totalProcessed,
      totalUpdated: totalUpdated,
      companyId: companyId,
      message: `Actualización completada: ${totalUpdated} documentos actualizados con companyId: ${companyId}`
    };

  } catch (error) {
    console.error('Error general:', error);
    return {
      success: false,
      error: error.message,
      message: 'Error durante la actualización masiva'
    };
  }
});

// Función para contar documentos que necesitan actualización
exports.countDocumentsToUpdate = functions.https.onCall({
  timeoutSeconds: 300,
  memory: '512MiB',
  maxInstances: 5
}, async (request) => {
  try {
    console.log('Contando documentos que necesitan actualización...');

    let totalCount = 0;
    let totalDocuments = 0;
    let hasMoreDocuments = true;
    let lastDocumentId = null;
    const batchSize = 1000;

    while (hasMoreDocuments) {
      let query = db.collection('invoices').limit(batchSize);

      if (lastDocumentId) {
        const lastDoc = await db.collection('invoices').doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfter(lastDoc);
        }
      }

      const snapshot = await query.get();

      if (snapshot.empty) {
        hasMoreDocuments = false;
        break;
      }

      // Contar documentos que necesitan actualización
      snapshot.forEach(doc => {
        const data = doc.data();
        totalDocuments++;

        if (!data.hasOwnProperty('companyId') || data.companyId === null) {
          totalCount++;
        }

        lastDocumentId = doc.id;
      });

      console.log(`Contando... ${totalDocuments} documentos revisados, ${totalCount} necesitan actualización`);

      if (snapshot.size < batchSize) {
        hasMoreDocuments = false;
      }
    }

    console.log(`Conteo completado: ${totalCount} de ${totalDocuments} documentos necesitan actualización`);

    return {
      success: true,
      totalDocuments: totalDocuments,
      documentsToUpdate: totalCount,
      message: `${totalCount} documentos necesitan ser actualizados de un total de ${totalDocuments}`
    };

  } catch (error) {
    console.error('Error contando documentos:', error);
    return {
      success: false,
      error: error.message
    };
  }
});

// Función para probar con un solo documento
exports.testSingleDocument = functions.https.onCall({
  timeoutSeconds: 60, // Menos tiempo para esta función simple
  memory: '256MiB',
  maxInstances: 10
}, async (request) => {
  try {
    const snapshot = await db.collection('invoices').limit(1).get();

    if (snapshot.empty) {
      return {
        success: false,
        message: 'No se encontraron documentos en la colección customers'
      };
    }

    const doc = snapshot.docs[0];
    const docData = doc.data();

    console.log('Documento de prueba:', {
      id: doc.id,
      hasCompanyId: docData.hasOwnProperty('companyId'),
      companyIdValue: docData.companyId,
      needsUpdate: !docData.hasOwnProperty('companyId') || docData.companyId === null
    });

    return {
      success: true,
      documentId: doc.id,
      hasCompanyId: docData.hasOwnProperty('companyId'),
      companyIdValue: docData.companyId,
      needsUpdate: !docData.hasOwnProperty('companyId') || docData.companyId === null,
      sampleData: Object.keys(docData), // Solo las claves para no exponer datos sensibles
      message: 'Documento de prueba obtenido exitosamente'
    };

  } catch (error) {
    console.error('Error en prueba:', error);
    return {
      success: false,
      error: error.message
    };
  }
});
