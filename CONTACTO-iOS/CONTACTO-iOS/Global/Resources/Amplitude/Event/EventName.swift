//
//  EventName.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import Foundation

struct EventInfo {
    let eventView: EventView
    let eventName: EventName
    let trigger: String
    
    init(event: EventView, eventName: EventName){
        self.eventView = event
        self.eventName = eventName
        self.trigger = eventName.trigger
    }
}

enum EventView: String {
    case ONBOARDING = "회원가입"
    case LOGIN = "로그인"
    case HOME = "홈"
    case DETAIL = "상세조회"
    case CHAT = "채팅"
    case EDIT = "편집"
    case INFO = "인포"
    case PUSH = "푸시 알림"
}

enum EventName: String {
    // Onboading
    case VIEW_ONBOARDING1
    case VIEW_ONBOARDING1_NEXT
    case VIEW_ONBOARDING2
    case VIEW_ONBOARDING2_NEXT
    case VIEW_ONBOARDING3
    case VIEW_ONBOARDING3_NEXT
    case VIEW_ONBOARDING4
    case VIEW_ONBOARDING4_NEXT
    case VIEW_ONBOARDING5
    case VIEW_ONBOARDING5_NEXT
    case VIEW_ONBOARDING6
    case VIEW_ONBOARDING6_NEXT
    
    // Login
    case VIEW_LOGIN
    case VIEW_NOACCOUNT
    case VIEW_INCORRECT
    case VIEW_SIGNUP
    case VIEW_EMAI_LCODE
    case VIEW_SET_PASSWORD
    case VIEW_SEND_CODE
    case VIEW_RESET_PASSWORD
    case VIEW_INPIT_NAME

    case CLICK_LOGIN_CONTINUE
    case CLICK_LOGIN_CREATE
    case CLICK_LOGIN_NEEDHELP
    case CLICK_LOGIN_BUTTON
    case CLICK_LOGIN_FIRST_STEP
    
    case CLICK_NOACCOUNT_CONTINUE
    case CLICK_NOACCOUNT_FORGET
    
    case CLICK_INCORRECT_LOGIN
    case CLICK_INCORRECT_FORGET
    
    case CLICK_SIGNUP_AGREE
    case CLICK_SIGNUP_AGREE_DETAIL
    case CLICK_SIGNUP_CONTINUE
    case CLICK_SIGNUP_BACK
    
    case CLICK_EMAIL_CODE_NEXT
    case CLICK_EMAIL_CODE_RESEND
    
    case CLICK_SET_PASSWORD_NEXT
    
    case CLICK_SEND_CODE_CONTINUE
    case CLICK_SEND_CODE_FORGET
    
    case CLICK_RESET_PASSWORD_NEXT
    case CLICK_INPUT_NAME_CONTINUE
    case CLICK_INPUT_NAME_FORGET
    case CLICK_INPUT_NAME_GO_TO_LOGIN
    
}

extension EventName {
    var trigger: String {
        switch self {
        case .VIEW_ONBOARDING1:
            return "이름 입력 온보딩 뷰"
        case .VIEW_ONBOARDING2:
            return "목적 선택 온보딩 뷰"
        case .VIEW_ONBOARDING3:
            return "설명 입력 온보딩 뷰"
        case .VIEW_ONBOARDING4:
            return "인스타 / 웹사이트 온보딩 뷰"
        case .VIEW_ONBOARDING5:
            return "탤런트 입력 온보딩 뷰"
        case .VIEW_ONBOARDING6:
            return "포트폴리오 입력 온보딩 뷰"
        
        case .VIEW_ONBOARDING1_NEXT:
            return "이름 입력 뷰에서 다음 버튼 클릭 시"
        case .VIEW_ONBOARDING2_NEXT:
            return "목적 선택 뷰에서 다음 버튼 클릭 시"
        case .VIEW_ONBOARDING3_NEXT:
            return "설명 입력 뷰에서 다음 버튼 클릭 시"
        case .VIEW_ONBOARDING4_NEXT:
            return "인스타 / 웹사이트 뷰에서 다음 버튼 클릭 시"
        case .VIEW_ONBOARDING5_NEXT:
            return "탤런트 입력 뷰에서 다음 버튼 클릭 시"
        case .VIEW_ONBOARDING6_NEXT:
            return "포트폴리오 입력 뷰에서 다음 버튼 클릭 시"
        
            
        case .VIEW_LOGIN:
            return "로그인 뷰"
        case .VIEW_NOACCOUNT:
            return "no account found 화면"
        case .VIEW_INCORRECT:
            return "incorrect password 화면"
        case .VIEW_SIGNUP:
            return "signup 화면"
        case .VIEW_EMAI_LCODE:
            return "이메일 코드 입력 뷰"
        case .VIEW_SET_PASSWORD:
            return "Set password 뷰"
        case .VIEW_SEND_CODE:
            return "Send a verification code 뷰"
        case .VIEW_RESET_PASSWORD:
            return "Reset Password 뷰"
        case .VIEW_INPIT_NAME:
            return "Input your Profile name (이메일 찾기 버튼 후 진입된) 뷰"
            
            
        case .CLICK_LOGIN_CONTINUE:
            return "이메일 입력 후 넘어갈 때"
        case .CLICK_LOGIN_CREATE:
            return "[Create a new account] 클릭 시"
        case .CLICK_LOGIN_NEEDHELP:
            return "[Need help signing in?] 클릭 시"
        case .CLICK_LOGIN_BUTTON:
            return "비밀번호 입력 후 로그인 버튼 클릭 시"
        case .CLICK_LOGIN_FIRST_STEP:
            return "[Go to First step] 클릭 시"

        case .CLICK_NOACCOUNT_CONTINUE:
            return "no account found 화면에서 [Continue] 버튼 선택 시"
        case .CLICK_NOACCOUNT_FORGET:
            return "no account found 화면에서 [Forget your E-mail?] 버튼 선택 시"


        case .CLICK_INCORRECT_LOGIN:
            return "incorrect password 화면에서 [Log in] 버튼 선택 시"
        case .CLICK_INCORRECT_FORGET:
            return "incorrect password 화면에서 [Forget your password?] 버튼 선택 시"

        case .CLICK_SIGNUP_AGREE:
            return "signup 화면에서 agree 버튼 선택 시"
        case .CLICK_SIGNUP_AGREE_DETAIL:
            return "signup 화면에서 see detail 버튼 선택 시"
        case .CLICK_SIGNUP_CONTINUE:
            return "signup 화면에서 continue 버튼 선택 시"
        case .CLICK_SIGNUP_BACK:
            return "signup 화면에서 [Back to Log in] 버튼 선택 시"

        case .CLICK_EMAIL_CODE_NEXT:
            return "이메일 코드 입력 뷰에서 next 버튼 선택 시"
        case .CLICK_EMAIL_CODE_RESEND:
            return "이메일 코드 입력 뷰에서 [Resend E-mail] 선택 시"

        case .CLICK_SET_PASSWORD_NEXT:
            return "Set password 뷰에서 next 버튼 선택 시"

            
        case .CLICK_SEND_CODE_CONTINUE:
            return "Send a verification code 에서 [Continue] 버튼 선택 시"
        case .CLICK_SEND_CODE_FORGET:
            return "Send a verification code 뷰에서 [Forget your E-mail?] 버튼 선택 시"

            
        case .CLICK_RESET_PASSWORD_NEXT:
            return "Reset Password 뷰에서 next 버튼 선택 시"

        case .CLICK_INPUT_NAME_CONTINUE:
            return "Input your Profile name 뷰에서 continue 버튼 선택 시"
        case .CLICK_INPUT_NAME_FORGET:
            return "Input your Profile name 뷰에서 [Forget your password] 버튼 선택 시"
        case .CLICK_INPUT_NAME_GO_TO_LOGIN:
            return "Input your Profile name 뷰에서 [Go to Log in] 버튼 선택 시"

        default:
            return "unknown"
        }
    }
}
