/* CREATE TABLE users (
  idUser INT AUTO_INCREMENT PRIMARY KEY,
  lastName VARCHAR(255) NOT NULL,
  firstName VARCHAR(255),
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  profilePhoto VARCHAR(255),
  birthDate DATE,
  gender VARCHAR(50),
  phone VARCHAR(50),
  city VARCHAR(100),
  role ENUM('admin', 'doctor', 'patient') NOT NULL DEFAULT 'patient',
  isVerified BOOLEAN NOT NULL DEFAULT 0,
  status ENUM('active', 'inactive', 'pending', 'suspended') DEFAULT 'active',
  suspendedBy INT NULL,
  suspendedAt DATETIME NULL,
  suspensionReason VARCHAR(255) NULL,
  lastLoginAt DATETIME NULL,
  deletedAt DATETIME NULL,
  createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (suspendedBy) REFERENCES users(idUser)
);

-- Table des demandes de passage médecin
CREATE TABLE doctor_applications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idUser INT NOT NULL,
  specialite VARCHAR(100) NOT NULL,
  diplomes TEXT NOT NULL,
  numero_inscription VARCHAR(100) NOT NULL,
  hopital VARCHAR(150) NOT NULL,
  adresse_consultation VARCHAR(255) NOT NULL,
  cni_front VARCHAR(255),
  cni_back VARCHAR(255),
  certification VARCHAR(255),
  cv_pdf VARCHAR(255),
  casier_judiciaire VARCHAR(255),
  status ENUM('pending', 'accepted', 'refused') NOT NULL DEFAULT 'pending',
  admin_message TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (idUser) REFERENCES users(idUser)
);

-- Table des médecins validés
CREATE TABLE doctor (
  id INT AUTO_INCREMENT PRIMARY KEY,
  idUser INT NOT NULL,
  specialite VARCHAR(100) NOT NULL,
  diplomes TEXT NOT NULL,
  numero_inscription VARCHAR(100) NOT NULL,
  hopital VARCHAR(150) NOT NULL,
  adresse_consultation VARCHAR(255) NOT NULL,
  experienceYears INT DEFAULT 0,
  pricePerHour DECIMAL(10,2) DEFAULT 0,
  description TEXT,
  note DECIMAL(3,2),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (idUser) REFERENCES users(idUser)
);

-- Table des créneaux de médecins
CREATE TABLE doctor_slots (
  id INT AUTO_INCREMENT PRIMARY KEY,
  doctorId INT NOT NULL,
  startDay VARCHAR(20) NOT NULL,
  startHour INT NOT NULL,
  startMinute INT NOT NULL,
  endDay VARCHAR(20) NOT NULL,
  endHour INT NOT NULL,
  endMinute INT NOT NULL,
  status ENUM('active', 'expired') NOT NULL DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_doctor_slot (doctorId, startDay, startHour, startMinute, endDay, endHour, endMinute),
  FOREIGN KEY (doctorId) REFERENCES doctor(id) ON DELETE CASCADE
);

-- Table des rendez-vous
CREATE TABLE rdv (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  specialty VARCHAR(100) NOT NULL,
  date DATETIME NOT NULL,
  status ENUM('pending', 'upcoming', 'completed', 'cancelled', 'no_show', 'doctor_no_show', 'both_no_show', 'expired', 'refused') NOT NULL DEFAULT 'pending',
  motif VARCHAR(255),
  duration_minutes INT NOT NULL DEFAULT 60,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES users(idUser),
  FOREIGN KEY (doctor_id) REFERENCES users(idUser)
);

-- Table des paiements (liée à un rdv)
CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rdv_id INT NOT NULL,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  platform_fee DECIMAL(12,2) NOT NULL,
  doctor_amount DECIMAL(12,2) NOT NULL,
  status ENUM('pending', 'success', 'failed', 'refunded', 'cancelled') NOT NULL DEFAULT 'pending',
  cinetpay_transaction_id VARCHAR(100),
  payment_method VARCHAR(50),
  paid_at DATETIME,
  refunded_at DATETIME,
  specialty VARCHAR(100),
  date DATETIME,
  motif VARCHAR(255),
  duration_minutes INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rdv_id) REFERENCES rdv(id) ON DELETE CASCADE,
  FOREIGN KEY (patient_id) REFERENCES users(idUser),
  FOREIGN KEY (doctor_id) REFERENCES users(idUser)
);

-- Table des remboursements
CREATE TABLE refunds (
  id INT AUTO_INCREMENT PRIMARY KEY,
  payment_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  status ENUM('pending', 'success', 'failed') NOT NULL DEFAULT 'pending',
  reason VARCHAR(255),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
);

-- Table des transactions (versements aux médecins)
CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  payment_id INT NOT NULL,
  doctor_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  status ENUM('pending', 'sent', 'failed') NOT NULL DEFAULT 'pending',
  sent_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES users(idUser)
);

-- Table des frais (plateforme, cinetpay...)
CREATE TABLE fees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  payment_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  type ENUM('cinetpay', 'platform') NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
);

-- Table des messages/notifications
CREATE TABLE messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT,
  receiver_id INT NOT NULL,
  application_id INT,
  subject VARCHAR(100),
  content TEXT NOT NULL,
  type ENUM('admin_reply', 'system', 'user_to_admin') DEFAULT 'admin_reply',
  is_read BOOLEAN DEFAULT FALSE,
  read_at DATETIME DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES users(idUser) ON DELETE SET NULL,
  FOREIGN KEY (receiver_id) REFERENCES users(idUser) ON DELETE CASCADE,
  FOREIGN KEY (application_id) REFERENCES doctor_applications(id) ON DELETE SET NULL
);

-- Table pour les pièces jointes lors de l'envoi d'un message.
CREATE TABLE message_attachments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  message_id INT NOT NULL,
  file_url VARCHAR(255) NOT NULL,
  file_type VARCHAR(50),
  uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE
);

-- Table des avis sur les médecins
CREATE TABLE doctor_reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  doctor_id INT NOT NULL,
  patient_id INT NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (doctor_id) REFERENCES doctor(id) ON DELETE CASCADE,
  FOREIGN KEY (patient_id) REFERENCES users(idUser) ON DELETE CASCADE
);

-- Table consultations
CREATE TABLE consultations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rdv_id INT NOT NULL,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  diagnostic TEXT NOT NULL,
  prescription TEXT NOT NULL,
  doctor_notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rdv_id) REFERENCES rdv(id) ON DELETE CASCADE,
  FOREIGN KEY (patient_id) REFERENCES users(idUser) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctor(id) ON DELETE CASCADE,
  INDEX idx_patient (patient_id),
  INDEX idx_doctor (doctor_id),
  INDEX idx_rdv (rdv_id)
);

-- Table consultation_files
CREATE TABLE consultation_files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  consultation_id INT NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  file_type VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (consultation_id) REFERENCES consultations(id) ON DELETE CASCADE
);

-- Table admins
CREATE TABLE admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL UNIQUE,
  adminRole ENUM('super_admin', 'admin', 'moderator') NOT NULL DEFAULT 'super_admin',
  createdBy INT NULL,
  notes TEXT,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (userId) REFERENCES users(idUser) ON DELETE CASCADE,
  FOREIGN KEY (createdBy) REFERENCES users(idUser)
);

-- Table pour les rappels de RDV envoyés
CREATE TABLE IF NOT EXISTS rdv_reminder_sent (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rdv_id INT NOT NULL,
  reminder_label VARCHAR(16) NOT NULL,
  sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_rdv_reminder (rdv_id, reminder_label),
  FOREIGN KEY (rdv_id) REFERENCES rdv(id) ON DELETE CASCADE
);
*/