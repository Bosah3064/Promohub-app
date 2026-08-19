const fs = require('fs');
const { getFirestore } = require('firebase-admin/firestore');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

const db = getFirestore();

async function seedCategories() {
  console.log('🚀 Starting categories import...');
  
  try {
    const data = fs.readFileSync('categories_rows.json', 'utf8');
    const categories = JSON.parse(data);
    
    console.log(`Found ${categories.length} categories to import.`);
    
    const batch = db.batch();
    let count = 0;
    
    for (const cat of categories) {
      const docRef = db.collection('categories').doc(cat.id);
      
      // Parse properties if it is a string
      let parsedProperties = cat.properties;
      if (typeof cat.properties === 'string') {
        try {
          parsedProperties = JSON.parse(cat.properties);
        } catch (e) {
          console.warn(`Could not parse properties for category ${cat.name}`);
        }
      }
      
      batch.set(docRef, {
        name: cat.name,
        description: cat.description || null,
        slug: cat.slug,
        icon: cat.icon || null,
        parent_id: cat.parent_id || null,
        properties: parsedProperties,
        is_active: cat.is_active,
        created_at: cat.created_at,
        updated_at: cat.updated_at,
        icon_url: cat.icon_url || null,
        order_index: cat.order_index || 0,
      });
      
      count++;
      
      // Firestore batch has a limit of 500 operations
      if (count % 400 === 0) {
        await batch.commit();
        console.log(`Committed ${count} categories...`);
      }
    }
    
    // Commit any remaining
    if (count % 400 !== 0) {
      await batch.commit();
    }
    
    console.log(`✅ Successfully imported ${count} categories!`);
  } catch (error) {
    console.error('Error importing categories:', error);
  }
}

seedCategories();
