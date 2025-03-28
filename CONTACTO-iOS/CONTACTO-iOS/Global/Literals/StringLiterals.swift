//
//  StringLiterals.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import Foundation

enum StringLiterals {
    enum Login {
        static let login = "Log in"
        static let email = "E-mail"
        static let continueButton = "Continue"
        
        static let createButton = "Create a new account"
        static let help = "Need help signing in?"
        static let privacy = "Privacy"
        
        static let pw = "password"
        static let forgetPwButton = "Forgot your password?"
        static let firstStepButton = "Go to First step"
        
        static let noAccountTitle = "No account found"
        static let noAccountDesc = "There’s no CONTACTO account with the info you provided.\nplease input correct e-mail or click below help button.".uppercased()
        static let forgetEmailButton = "Forgot your E-mail?"
        
        static let incorrectPWTitle = "Incorrect password"
        static let incorrectPWDesc = "please input correct password or click below help button.".uppercased()
        
        static let signUp = "Sign Up"
        static let agreePrivacy = "agree privacy policy".uppercased()
        static let detailButton = "see detail".uppercased()
        static let needHelp = "Need help signing in?"
        static let backToLogin = "Back to Log in"
        
        static let sendCode = "Send a verification code"
        static let verify = "E-mail verification code"
        static let nextButton = "Next"
        static let resendButton = "Resend E-mail"
        
        static let setPW = "Set password"
        static let resetPW = "Reset password"
        static let condition1 = "at least 8 char.".uppercased()
        static let condition2 = "at least 1 special char.".uppercased()
        static let condition3 = "at least 1 number".uppercased()
        static let confirmPW = "confirm password"
        
        static let inputName = "Input your Profile name."
        static let name = "name"
        static let yourEmail = "Your E-mail is"
        static let goToLogin = "Go to Log in"
    }
    
    enum Onboarding {
        enum Name {
            static let title = "LET ME KNOW\nYOUR NAME"
            static let description = "BRAND NAME, PEN NAME, ARTIST NAME ETC..."
            static let example = "ex. CONTACTO"
        }
        
        enum Purpose {
            static let title = "WHAT'S YOUR\nPURPOSE?"
            static let description = "MULTIPLE SELECTION"
            static let getalong = "# Get Along With U"
            static let collaborate = "# Collaborate Project"
            static let makenew = "# Make New Brand"
            static let art = "# Art Residency"
            static let group = "# Group exhibition"
        }
        
        enum Explain {
            static let title = "EXPLAIN YOUR\nORIGINALITY"
            static let example = "ex) We are make a ceramic for design."
        }
        
        enum SNS {
            static let title = "DO YOU HAVE\nSNS & WEBSITE"
            static let instagram = "INSTAGRAM"
            static let required = "REQUIRED*"
            static let website = "WEBSITE"
            static let example = "https://contactocreator.com"
        }
        
        enum Talent {
            static let title = "WHAT'S YOUR\nTALENT?"
            static let design = "DESIGN & FASHION"
            static let art = "ART & CRAFT"
            static let media = "MEDIA & CONTENTS"
        }
        
        enum Portfolio {
            static let title = "SHOW YOUR\nBEST PORTFOLIO"
            static let upload = "Upload"
        }
    }
    
    enum Home {
        enum Main {
            static let title = "Profile by"
            static let emptyTitle = "End\nAnd"
            static let emptyDescription = "You swipe all!\nNew Artist will come soon!"
        }
        
        enum Profile {
            static let purpose = "-\nLooking for"
            static let insta = "-\ninstagram"
            static let website = "-\nwebsite"
            static let block = "Block"
            static let report = "Report"
        }
        
        enum Block {
            static let title = "User Block"
            static let message = "Are you sure you want to\nblock this user?"
            static let result = "User blocked successfully. It may take some time for the block to be fully applied."
        }
        
        enum Report {
            static let title = "User Report"
            static let result = "Your report has been submitted successfully. We will review it and take appropriate action."
            enum ReportReasons {
                static let spam = "Spam"
                static let sexualOffense = "Sexual offense against children and youth"
                static let profanity = "Profanity, violence, hatred"
                static let illegalProducts = "Illegal products or services"
                static let abnormalService = "Abnormal service use"
                static let fraud = "Fraud, identity theft"
                static let obsceneActs = "Obscene, sexual acts"
                
                static let allCases = [
                    spam,
                    sexualOffense,
                    profanity,
                    illegalProducts,
                    abnormalService,
                    fraud,
                    obsceneActs
                ]
            }
        }
        
        enum Match {
            static let title = "Oh! You both like each ohter"
            static let description = "just say hello"
            static let hello = "hello!"
            static let nice = "Nice to meet you!"
            static let hi = "HI"
            static let oh = "Oh!"
        }
    }
    
    enum Chat {
        enum Empty {
            static let title = "Not\nYet"
            static let description = "If we find first match,\nWe’ll notice you on push."
        }
        
        enum Disclaimer {
            static let title = "Congratulation!"
            static let description = "We think you both have a lot in common.\nFeel free to talk comfortably."
        }
    }
    
    enum Edit {
        static let profileEdit = "Profile Edit"
        static let preview = "Preview"
        static let upload = "upload"
        static let talent = "Talent"
        static let originality = "My Originality"
        static let purpose = "Purpose"
        static let sns = "SNS & Web Site"
        static let instagram = "INSTAGRAM"
        static let required = "REQUIRED*"
        static let website = "WEBSITE"
        static let example = "https://contactocreator.com"
        static let editButton = "EDIT START"
        static let saveButton = "SAVE"
        static let doneButton = "Done"
    }
    
    enum Info {
        static let account = "Account Setting"
        static let email = "E-mail"
        static let password = "Password"
        static let help = "Help & Support"
        static let guidelines = "Community Guidelines"
        static let privacy = "Privacy"
        static let logout = "Log out"
        static let delete = "Delete Account"
        
        enum Alert {
            enum Logout {
                static let logoutTitle = "Log out"
                static let logoutDescription = "Are you sure you want to\nlog out CONTACTO?"
                static let yes = "Yes"
                static let no = "No"
                
            }
            
            enum Delete {
                static let deleteTitle = "Delete Account"
                static let deleteDescription = "Deleting your account will remove all of\nyour information from our database.\nThis cannot be undone."
                static let notYet = "Not yet"
                static let delete = "Delete"
            }
        }
    }
    
    enum URL {
        static let insta =
            "https://www.instagram.com/contacto.creator"
        static let guidelines = "https://pomus.notion.site/1437a75859a880deb38afb0ead0f8b39?pvs=4"
        static let privacy = "https://contactocreator.notion.site/1437a75859a88040b512e1a9b98228ac?pvs=4"
    }
}
