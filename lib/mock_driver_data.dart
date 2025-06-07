class Driver {
  final String id;
  final String name;
  final String surname;
  final String phone;
  final String licenseNumber;
  final String status;
  final String note;
  final String addedBy;

  Driver({
    required this.id,
    required this.name,
    required this.surname,
    required this.phone,
    required this.licenseNumber,
    required this.status,
    required this.note,
    required this.addedBy,
  });
}

// Test üçün cari istifadəçi ID-si
const String currentUserId = 'user123';

// Demo məlumatlar
List<Driver> allDrivers = [
  Driver(
    id: '1',
    name: 'Murad',
    surname: 'Əliyev',
    phone: '+994501234567',
    licenseNumber: 'SV00123',
    status: 'Problemli',
    note: 'Borcu var',
    addedBy: 'user123',
  ),
  Driver(
    id: '2',
    name: 'Rəşad',
    surname: 'Quliyev',
    phone: '+994502345678',
    licenseNumber: 'SV00987',
    status: 'Problemsiz',
    note: '',
    addedBy: 'user456',
  ),
];
