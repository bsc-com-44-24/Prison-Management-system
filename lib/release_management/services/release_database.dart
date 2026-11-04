import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReleaseDatabase {
ReleaseDatabase._();

static final ReleaseDatabase instance = ReleaseDatabase._();

Database? _database;

Future<Database> get database async {
if (_database != null) return _database!;

final path = join(
  await getDatabasesPath(),
  'prison_mgmt.db',
);

_database = await openDatabase(
  path,
  version: 1,
);

await _createReleaseTable(_database!);

return _database!;
}

Future<void> _createReleaseTable(Database db) async {
await db.execute('''
CREATE TABLE IF NOT EXISTS releases (
id INTEGER PRIMARY KEY AUTOINCREMENT,
inmate_id TEXT NOT NULL UNIQUE,
release_date TEXT NOT NULL,
verification_status TEXT NOT NULL DEFAULT 'Pending',
clearance_status TEXT NOT NULL DEFAULT 'Pending',
approval_status TEXT NOT NULL DEFAULT 'Pending',
release_status TEXT NOT NULL DEFAULT 'Upcoming',
created_at TEXT NOT NULL
)
''');
}

// Register an inmate for release processing.
Future<int> addRelease({
required String inmateId,
required String releaseDate,
}) async {
final db = await database;

return await db.insert(
  'releases',
  {
    'inmate_id': inmateId,
    'release_date': releaseDate,
    'created_at': DateTime.now().toIso8601String(),
  },
  conflictAlgorithm: ConflictAlgorithm.ignore,
);
}

// Retrieve all release records.
Future<List<Map<String, Object?>>> getAllReleases() async {
final db = await database;

return await db.query(
  'releases',
  orderBy: 'release_date ASC',
);
}

// Retrieve upcoming releases.
Future<List<Map<String, Object?>>> getUpcomingReleases() async {
final db = await database;

return await db.query(
  'releases',
  where: "release_status != ?",
  whereArgs: ['Released'],
  orderBy: 'release_date ASC',
);
}

// Retrieve completed releases.
Future<List<Map<String, Object?>>> getReleasedInmates() async {
final db = await database;


return await db.query(
  'releases',
  where: 'release_status = ?',
  whereArgs: ['Released'],
  orderBy: 'release_date DESC',
);
}

// Update a release processing stage.
Future<int> updateStage({
required int releaseId,
required String column,
required String status,
}) async {
const allowedColumns = [
'verification_status',
'clearance_status',
'approval_status',
'release_status',
];

if (!allowedColumns.contains(column)) {
  throw ArgumentError('Invalid release stage');
}

final db = await database;

return await db.update(
  'releases',
  {column: status},
  where: 'id = ?',
  whereArgs: [releaseId],
);
}

// Delete a release record.
Future<int> deleteRelease(int id) async {
final db = await database;

return await db.delete(
  'releases',
  where: 'id = ?',
  whereArgs: [id],
);
}
}
