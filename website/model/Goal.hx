package model;

enum abstract Goal(String) from String to String {
    var LogsDeleted = "log";
    var SystemsCorrupted = "corrup";
    var SystemsCrashed = "crash";
    var PasswordCracked = "passwd";
    var RessourcesExtracted = "eextra";
    var FilesExtracted = "mextra";
    var AntivirusKilled = "av";
    var MissionsFulfilled = "success";
    var MissionsWithoutFailure = "firsttry";

    static public function description(goal: Goal) {
        switch (goal) {
            case LogsDeleted:
                return "Traces effacees";
            case SystemsCorrupted:
                return "Systemes corrompus";
            case SystemsCrashed:
                return "Systemes detruits";
            case PasswordCracked:
                return "Mots de passes crackes";
            case RessourcesExtracted:
                return "Extraction de ressources";
            case FilesExtracted:
                return "Extraction de fichiers de valeur";
            case AntivirusKilled:
                return "Suppression d'antivirus";
            case MissionsFulfilled:
                return "Missions remplies";
            case MissionsWithoutFailure:
                return "Missions sans echec";
        }
    }
  }
