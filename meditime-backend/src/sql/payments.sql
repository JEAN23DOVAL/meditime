-- Table des paiements (liée à un rdv)
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rdv_id INT NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    platform_fee DECIMAL(12,2) NOT NULL,
    doctor_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed', 'refunded', 'cancelled')),
    cinetpay_transaction_id VARCHAR(100),
    payment_method VARCHAR(50),
    paid_at DATETIME,
    refunded_at DATETIME,
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
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed')),
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
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
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
    type VARCHAR(20) NOT NULL CHECK (type IN ('cinetpay', 'platform')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
);
-- Ajoute ces colonnes si elles n'existent pas déjà
ALTER TABLE payments
  ADD COLUMN specialty VARCHAR(100) NULL,
  ADD COLUMN date DATETIME NULL,
  ADD COLUMN motif VARCHAR(255) NULL,
  ADD COLUMN duration_minutes INT NULL;