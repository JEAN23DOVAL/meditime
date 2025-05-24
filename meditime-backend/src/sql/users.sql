/* CREATE TABLE users (
  idUser INT IDENTITY(1,1) PRIMARY KEY,
  lastName VARCHAR(255) NOT NULL,
  firstName VARCHAR(255),
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  profilePhoto VARCHAR(255),
  birthDate DATE,
  gender VARCHAR(50),
  phone VARCHAR(50),
  city VARCHAR(100),
  role VARCHAR(20) NOT NULL DEFAULT 'patient' CHECK (role IN ('admin', 'doctor', 'patient')),
  isVerified BIT NOT NULL DEFAULT 0,
  createdAt DATETIME NOT NULL DEFAULT GETDATE(),
  updatedAt DATETIME NOT NULL DEFAULT GETDATE()
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
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'refused')),
    admin_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (idUser) REFERENCES users(idUser)
);

-- Table des messages/notifications
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT,
    receiver_id INT NOT NULL,
    application_id INT, -- OK car doctor_applications.id est INT aussi
    subject VARCHAR(100),
    content TEXT NOT NULL,
    type ENUM('admin_reply', 'system', 'user_to_admin') DEFAULT 'admin_reply',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sender_id) REFERENCES users(idUser) ON DELETE SET NULL,
    FOREIGN KEY (receiver_id) REFERENCES users(idUser) ON DELETE CASCADE,
    FOREIGN KEY (application_id) REFERENCES doctor_applications(id) ON DELETE SET NULL
);

-- Table pour les pièces jontes lors de l'envoie d'un message.
CREATE TABLE message_attachments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_type VARCHAR(50), -- pdf, image, etc.
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE
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
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (idUser) REFERENCES users(idUser)
); 

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
);*/