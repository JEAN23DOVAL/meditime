import 'package:flutter/material.dart';
import 'package:meditime_frontend/features/home/user/accueil/home_page';
import 'package:meditime_frontend/features/home/user/doctors/doctors_page.dart';
import 'package:meditime_frontend/features/home/user/messages/messages_page.dart';
import 'package:meditime_frontend/features/home/user/profile/profile_page.dart';
import 'package:meditime_frontend/features/home/user/rdv/rdv_page.dart';/* 
import 'package:meditime_frontend/features/home/pages/home_page.dart';
import 'package:meditime_frontend/features/home/pages/rdv_page.dart';
import 'package:meditime_frontend/features/home/pages/messages_page.dart';*/

List<Widget> buildHomePages({required bool isDoctor}) => [
  const HomePage(),
  DoctorPage(),
  RdvPage(isDoctor: isDoctor),
  const MessagesPage(),
  const ProfilPage(), 
];