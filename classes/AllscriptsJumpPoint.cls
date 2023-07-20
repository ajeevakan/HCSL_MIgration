public without sharing class AllscriptsJumpPoint  {

    public String ASUserName{get;set;}
    public String ASPassword{get;set;}    
       
    public AllscriptsJumpPoint (ApexPages.StandardController stdController) {

           System.Debug('AllScriptsJumpPoint Controller: AllScriptsJumpPoint 1: ' + ASUserName);
           if (Cache.Session.contains('ASUserName')) {
              ASUserName = (String)Cache.Session.get('ASUserName');
              System.Debug('AllScriptsJumpPoint Controller: AllScriptsJumpPoint 2: ' + ASUserName);
           }
           else if (ASUserName  != null) {
              Cache.Session.put('ASUserName', ASUserName  );
              System.Debug('AllScriptsJumpPoint Controller: AllScriptsJumpPoint 3: ' + ASUserName);
           }
           System.Debug('AllScriptsJumpPoint Controller: AllScriptsJumpPoint 4: ' + ASUserName);
           if (Cache.Session.contains('ASPassword'))
              ASPassword = (String)Cache.Session.get('ASPassword');
           else if (ASPassword  != null)
              Cache.Session.put('ASPassword', ASPassword );
    }
    
      public void saveUserName2 () {
   
       System.Debug('AllScriptsJumpPoint Controller: updatedUserName2: ' + ASUserName);
       if (ASUserName != null) {
          Cache.Session.put('ASUserName', ASUserName);
          System.Debug('AllScriptsJumpPoint Controller: saveUserName 1: ' + ASUserName);
          System.Debug('AllScriptsJumpPoint Controller: saveUserName getKeys(): ' + Cache.Session.getKeys());
          
           if (Cache.Session.contains('ASUserName')) {
              System.Debug('AllScriptsJumpPoint Controller: saveUserName 2: ' + Cache.Session.get('ASUserName'));
           }
       }
     
    }
    
public void savePassWord2 () {
   
       System.Debug('AllScriptsJumpPoint Controller: ASPassword: ' + ASPassword);
       if (ASPassword != null) {
          Cache.Session.put('ASPassword', ASPassword);
          System.Debug('AllScriptsJumpPoint Controller: ASPassword 1: ' + ASPassword);
          System.Debug('AllScriptsJumpPoint Controller: ASPasswordgetKeys(): ' + Cache.Session.getKeys());
          
           if (Cache.Session.contains('ASPassword')) {
              System.Debug('AllScriptsJumpPoint Controller: ASPassword2: ' + Cache.Session.get('ASPassword'));
           }
       }
     
    }     
}