import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  bool _isEnglish = true;

  String get lang => _isEnglish ? 'en' : 'fr';
  bool get isEnglish => _isEnglish;

  void setLanguage(String code) {
    final next = code.toLowerCase() == 'en';
    if (_isEnglish == next) return;
    _isEnglish = next;
    notifyListeners();
  }

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  String t(String key) => translate(key);

  String translate(String key) {
    return _isEnglish ? (_en[key] ?? key) : (_fr[key] ?? key);
  }

  static const Map<String, String> _en = {
    // Auth
    'login': 'Login',
    'signup': 'Sign Up',
    'select_role': 'Select Your Role',
    'driver': 'Driver',
    'advertiser': 'Advertiser',
    'vendor': 'Vendor',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'drive_advertise_earn': 'Drive. Advertise. Earn.',
    'or': 'OR',
    'continue_google': 'Continue with Google',
    'continue_apple': 'Continue with Apple',
    'continue_facebook': 'Continue with Facebook',
    'passwords_no_match': 'Passwords do not match',

    // Common
    'dashboard': 'Dashboard',
    'welcome_back': 'Welcome back',
    'statistics': 'Statistics',
    'logout': 'Logout',
    'active': 'Active',
    'pending': 'Pending',
    'inactive': 'Inactive',
    'create': 'Create',
    'create_campaign': 'Create Campaign',
    'language': 'Language',
    'view_applicants': 'View Applicants',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'view_all': 'View All',

    // Campaign Management
    'campaign_name': 'Campaign Name',
    'description': 'Description',
    'budget': 'Budget',
    'duration_days': 'Duration',
    'location': 'Location',
    'delete_campaign': 'Delete Campaign',
    'delete_confirm': 'Are you sure you want to delete',
    'delete_warning': 'This action cannot be undone.',
    'deleted': 'deleted',
    'undo': 'UNDO',
    'campaign_updated': 'Campaign updated successfully',
    'campaign_created': 'Campaign created successfully',
    'edit_campaign': 'Edit Campaign',
    'no_campaigns': 'No campaigns',
    'no_campaigns_yet': 'No campaigns yet',
    'create_first_campaign': 'Create First Campaign',

    // Driver Dashboard
    'total_earnings': 'Total Earnings',
    'active_campaigns': 'Active Campaigns',
    'completed_campaigns': 'Completed Campaigns',
    'monthly_earnings': 'Monthly Earnings',
    'live_campaign_map': 'Live Campaign Map',
    'location_calgary': 'Location: Downtown Calgary',
    'active_zone': 'Active Zone',
    'recent_activity': 'Recent Activity',

    // Advertiser Dashboard
    'total_spent': 'Total Spent',
    'impressions': 'Impressions',
    'reach': 'Reach',
    'my_campaigns': 'My Campaigns',
    'open_campaigns': 'Open Campaigns',
    'view_analytics': 'View Analytics',

    // Navigation
    'campaigns': 'Campaigns',
    'applications': 'Applications',
    'earnings': 'Earnings',
    'analytics': 'Analytics',
    'profile': 'Profile',

    // Applications Page
    'track_applications': 'Track your applications here',
    'applied_on': 'Applied on',
    'vehicle_info': 'Vehicle Information',
    'install_scheduled': 'Installation Scheduled',
    'approved': 'Approved',

    // Campaigns Page
    'available_campaigns': 'Available Campaigns',
    'duration': 'Duration',
    'applicants': 'Applicants',
    'drivers': 'Drivers',

    // Earnings Page
    'recent_transactions': 'Recent Transactions',

    // Analytics Page
    'campaign_performance': 'Campaign Performance',
    'impressions_reach_time': 'Impressions & Reach Over Time',
    'avg_impressions': 'Average Impressions/Campaign',
    'avg_reach': 'Average Reach/Campaign',
    'engagement_rate': 'Engagement Rate',
    'from_last_month': 'from last month',

    // Profile Page
    'manage_profile_vehicle': 'Manage your profile and vehicle information',
    'personal_info': 'Personal Information',
    'name': 'Name',
    'phone': 'Phone',
    'license_number': 'License Number',
    'make': 'Make',
    'model': 'Model',
    'year': 'Year',
    'license_plate': 'License Plate',
  };

  static const Map<String, String> _fr = {
    // Auth
    'login': 'Connexion',
    'signup': 'Inscription',
    'select_role': 'Sélectionnez votre rôle',
    'driver': 'Conducteur',
    'advertiser': 'Annonceur',
    'vendor': 'Vendeur',
    'email': 'Email',
    'password': 'Mot de passe',
    'confirm_password': 'Confirmer le mot de passe',
    'drive_advertise_earn': 'Conduisez. Annoncez. Gagnez.',
    'or': 'OU',
    'continue_google': 'Continuer avec Google',
    'continue_apple': 'Continuer avec Apple',
    'continue_facebook': 'Continuer avec Facebook',
    'passwords_no_match': 'Les mots de passe ne correspondent pas',

    // Common
    'dashboard': 'Tableau de bord',
    'welcome_back': 'Bon retour',
    'statistics': 'Statistiques',
    'logout': 'Déconnexion',
    'active': 'Actif',
    'pending': 'En attente',
    'inactive': 'Inactif',
    'create': 'Créer',
    'create_campaign': 'Créer une campagne',
    'language': 'Langue',
    'view_applicants': 'Voir les candidats',
    'save': 'Enregistrer',
    'cancel': 'Annuler',
    'delete': 'Supprimer',
    'edit': 'Modifier',
    'view_all': 'Voir tout',

    // Campaign Management
    'campaign_name': 'Nom de la campagne',
    'description': 'Description',
    'budget': 'Budget',
    'duration_days': 'Durée',
    'location': 'Lieu',
    'delete_campaign': 'Supprimer la campagne',
    'delete_confirm': 'Êtes-vous sûr de vouloir supprimer',
    'delete_warning': 'Cette action ne peut pas être annulée.',
    'deleted': 'supprimé',
    'undo': 'ANNULER',
    'campaign_updated': 'Campagne mise à jour avec succès',
    'campaign_created': 'Campagne créée avec succès',
    'edit_campaign': 'Modifier la campagne',
    'no_campaigns': 'Aucune campagne',
    'no_campaigns_yet': 'Aucune campagne pour le moment',
    'create_first_campaign': 'Créer la première campagne',

    // Driver Dashboard
    'total_earnings': 'Gains totaux',
    'active_campaigns': 'Campagnes actives',
    'completed_campaigns': 'Campagnes terminées',
    'monthly_earnings': 'Gains mensuels',
    'live_campaign_map': 'Carte des campagnes',
    'location_calgary': 'Lieu: Calgary centre-ville',
    'active_zone': 'Zone active',
    'recent_activity': 'Activité récente',

    // Advertiser Dashboard
    'total_spent': 'Total dépensé',
    'impressions': 'Impressions',
    'reach': 'Portée',
    'my_campaigns': 'Mes campagnes',
    'open_campaigns': 'Campagnes ouvertes',
    'view_analytics': 'Voir les analyses',

    // Navigation
    'campaigns': 'Campagnes',
    'applications': 'Candidatures',
    'earnings': 'Gains',
    'analytics': 'Analyses',
    'profile': 'Profil',

    // Applications Page
    'track_applications': 'Suivez vos candidatures ici',
    'applied_on': 'Postulé le',
    'vehicle_info': 'Informations sur le véhicule',
    'install_scheduled': 'Installation planifiée',
    'approved': 'Approuvé',

    // Campaigns Page
    'available_campaigns': 'Campagnes disponibles',
    'duration': 'Durée',
    'applicants': 'Candidats',
    'drivers': 'Conducteurs',

    // Earnings Page
    'recent_transactions': 'Transactions récentes',

    // Analytics Page
    'campaign_performance': 'Performance de la campagne',
    'impressions_reach_time': 'Impressions et portée au fil du temps',
    'avg_impressions': 'Moyenne d\'impressions/campagne',
    'avg_reach': 'Portée moyenne/campagne',
    'engagement_rate': 'Taux d\'engagement',
    'from_last_month': 'par rapport au mois dernier',

    // Profile Page
    'manage_profile_vehicle':
        'Gérez votre profil et les informations de votre véhicule',
    'personal_info': 'Informations personnelles',
    'name': 'Nom',
    'phone': 'Téléphone',
    'license_number': 'Numéro de permis',
    'make': 'Marque',
    'model': 'Modèle',
    'year': 'Année',
    'license_plate': 'Plaque d\'immatriculation',
  };
}
