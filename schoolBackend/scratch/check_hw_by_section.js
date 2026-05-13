const pool = require('../src/config/db');

async function checkHomework() {
  try {
    console.log("--- Sections ---");
    const [sections] = await pool.query("SELECT id, name FROM sections");
    console.log(sections);

    for (const section of sections) {
        console.log(`\n--- Homework for Section ${section.name} (ID: ${section.id}) ---`);
        const [hw] = await pool.query("SELECT id, title, section_id, created_at FROM homework WHERE section_id = ?", [section.id]);
        console.log(hw);
    }

    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

checkHomework();
