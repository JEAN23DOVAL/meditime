// 📁 src/controllers/auth.controller.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const path = require('path');
const fs = require('fs');
const User = require('../models/user_model');
const generateToken = require('../utils/generateToken');
const { hashPassword, comparePassword } = require('../utils/hashPassword');
const formatPhotoUrl = require('../utils/formatPhotoUrl');
const { emitToUser } = require('../utils/wsEmitter');

// ✅ Inscription utilisateur (avec upload image)
const registerUser = async (req, res) => {
  try {
    const { lastName, firstName, email, password, birthDate, gender, phone, city } = req.body;

    // 📸 Gérer l'image de profil uploadée (si présente)
    let profilePhotoPath = null;
    if (req.file) {
      profilePhotoPath = req.file.filename;
    }

    // 🔐 Hasher le mot de passe
    const hashedPassword = await hashPassword(password);

    // 📦 Créer l'utilisateur
    const newUser = await User.create({
      lastName,
      firstName,
      email,
      password: hashedPassword,
      profilePhoto: profilePhotoPath,
      birthDate, // <-- Sequelize gère "YYYY-MM-DD" automatiquement
      gender,
      phone,
      city
    });

    // 🔑 Générer un token JWT
    const token = await generateToken(newUser);

    // ✅ Réponse
    res.status(201).json({
      message: 'Inscription réussie',
      user: {
        id: newUser.idUser,
        lastName: newUser.lastName,
        firstName: newUser.firstName,
        email: newUser.email,
        profilePhoto: newUser.profilePhoto
          ? formatPhotoUrl(newUser.profilePhoto, req)
          : null,
        birthDate: newUser.birthDate,
        gender: newUser.gender,
        phone: newUser.phone,
        city: newUser.city,
        role: newUser.role,
        isVerified: newUser.isVerified,
        status: newUser.status,
        lastLoginAt: newUser.lastLoginAt
      },
      token
    });
  } catch (error) {
    console.error('❌ Erreur inscription:', error);
    res.status(500).json({ error: 'Erreur serveur pendant l\'inscription' });
  }
};

// ✅ Connexion utilisateur
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 🔍 Rechercher l'utilisateur
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    // 🔐 Comparer le mot de passe
    const isPasswordValid = await comparePassword(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    // 🕒 Mettre à jour la date de dernière connexion
    user.lastLoginAt = new Date();
    await user.save();

    // 🔑 Générer un token JWT
    const token = await generateToken(user);

    // ✅ Réponse
    res.status(200).json({
      message: 'Connexion réussie',
      user: {
        id: user.idUser,
        lastName: user.lastName,
        firstName: user.firstName,
        email: user.email,
        profilePhoto: user.profilePhoto
          ? formatPhotoUrl(user.profilePhoto, req)
          : null,
        birthDate: user.birthDate,
        gender: user.gender,
        phone: user.phone,
        city: user.city,
        role: user.role,
        isVerified: user.isVerified,
        status: user.status,
        lastLoginAt: user.lastLoginAt
      },
      token
    });
  } catch (error) {
    console.error('❌ Erreur connexion:', error);
    res.status(500).json({ error: 'Erreur serveur pendant la connexion' });
  }
};

// ✅ Mise à jour du profil utilisateur
const updateProfile = async (req, res) => {
  try {
    const { lastName, firstName, email, city, phone, gender, birthDate } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({ message: "Utilisateur non trouvé" });
    }

    // Gérer la photo de profil si présente
    let profilePhotoPath = user.profilePhoto;
    if (req.file) {
      // Supprimer l'ancienne photo si elle existe et est différente de la nouvelle
      if (user.profilePhoto) {
        const oldPath = path.join(__dirname, '../uploads/photo_profil', user.profilePhoto);
        if (fs.existsSync(oldPath)) {
          fs.unlinkSync(oldPath);
        }
      }
      profilePhotoPath = req.file.filename;
    }

    // Mettre à jour les champs
    user.lastName = lastName;
    user.firstName = firstName;
    user.city = city;
    user.phone = phone;
    user.gender = gender;
    user.birthDate = birthDate && !isNaN(Date.parse(birthDate)) ? new Date(birthDate) : null;
    user.profilePhoto = profilePhotoPath;

    // Vérifier si tous les champs sont remplis pour valider isVerified
    const allFieldsFilled =
      user.lastName &&
      user.firstName &&
      user.email &&
      user.city &&
      user.phone &&
      user.gender &&
      user.birthDate &&
      user.profilePhoto;
    user.isVerified = !!allFieldsFilled;

    await user.save();
    // Temps réel : notifier l'utilisateur de la mise à jour de son profil
    emitToUser(req.app, user.idUser, 'profile_update', { user });

    // Générer un nouveau token avec les infos à jour
    const token = generateToken(user);

    // Après updateProfile
    emitToUser(req.app, user.idUser, 'profile_update', { user });

    res.status(200).json({
      message: "Profil mis à jour avec succès",
      user: {
        idUser: user.idUser,
        lastName: user.lastName,
        firstName: user.firstName,
        email: user.email,
        profilePhoto: user.profilePhoto
          ? formatPhotoUrl(user.profilePhoto, req)
          : null,
        birthDate: user.birthDate,
        gender: user.gender,
        phone: user.phone,
        city: user.city,
        role: user.role,
        isVerified: user.isVerified,
        status: user.status,
        lastLoginAt: user.lastLoginAt
      },
      token
    });
  } catch (error) {
    console.error("❌ Erreur mise à jour profil:", error);
    res.status(500).json({ message: "Erreur serveur pendant la mise à jour du profil" });
  }
};

module.exports = {
  registerUser,
  loginUser,
  updateProfile,
};