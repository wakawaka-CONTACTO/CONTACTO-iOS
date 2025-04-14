//
//  EventTrigger.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/10/25.
//

import Foundation

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
        
        case .CLICK_ONBOARDING1_NEXT:
            return "이름 입력 뷰에서 다음 버튼 클릭 시"
        case .CLICK_ONBOARDING2_NEXT:
            return "목적 선택 뷰에서 다음 버튼 클릭 시"
        case .CLICK_ONBOARDING3_NEXT:
            return "설명 입력 뷰에서 다음 버튼 클릭 시"
        case .CLICK_ONBOARDING4_NEXT:
            return "인스타 / 웹사이트 뷰에서 다음 버튼 클릭 시"
        case .CLICK_ONBOARDING5_NEXT:
            return "탤런트 입력 뷰에서 다음 버튼 클릭 시"
        case .CLICK_ONBOARDING6_NEXT:
            return "포트폴리오 입력 뷰에서 다음 버튼 클릭 시"
        
            
        case .VIEW_LOGIN:
            return "로그인 뷰"
        case .VIEW_NOACCOUNT:
            return "no account found 화면"
        case .VIEW_INCORRECT:
            return "incorrect password 화면"
        case .VIEW_SIGNUP:
            return "signup 화면"
        case .VIEW_EMAIL_CODE:
            return "이메일 코드 입력 뷰"
        case .VIEW_SET_PASSWORD:
            return "Set password 뷰"
        case .VIEW_SEND_CODE:
            return "Send a verification code 뷰"
        case .VIEW_RESET_PASSWORD:
            return "Reset Password 뷰"
        case .VIEW_INPUT_NAME:
            return "Input your Profile name (이메일 찾기 버튼 후 진입된) 뷰"
        case .VIEW_HOME:
            return "로그인 이후 보여진 홈 뷰"
        case .VIEW_HOME_TUTORIAL:
            return "홈 화면의 튜토리얼 확인 시"
        case .VIEW_MATCH:
            return "match 화면 떴을 때"
        case .VIEW_HOME_EMPTY:
            return "empty 화면 보일 때"
            
            
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
        
        case .CLICK_HOME_BACK:
            return "포트폴리오 이전으로 돌릴 때"
        case .CLICK_HOME_NEXT:
            return "포트폴리오 다음으로 넘길 때"
        case .CLICK_HOME_PROFILE:
            return "프로필 버튼 눌렀을 때"
        case .CLICK_HOME_YES:
            return "Yes 버튼 클릭 / Yes 스와이프"
        case .CLICK_HOME_NO:
            return "No 버튼 클릭 / No 스와이프"
        case .CLICK_HOME_REVERT:
            return "되돌리기 버튼 눌렀을 때"
            
            
        case .SUCCESS_LOGIN:
            return "Login 성공"
            
        case .VIEW_DETAIL:
            return "디테일 화면"
        case .SCROLL_DETAIL:
            return "디테일 화면 스크롤 시"
        case .CLICK_DETAIL_BACK:
            return "디테일 화면 나갈 때"
        case .CLICK_DETAIL_INSTA:
            return "인스타그램 버튼 클릭 시"
        case .CLICK_DETAIL_WEB:
            return "웹 버튼 클릭 시"
        case .CLICK_DETAIL_BLOCK_YES:
            return "block 버튼 클릭 시"
        case .CLICK_DETAIL_BLOCK_NO:
            return "block no 버튼 클릭 시"
        case .CLICK_DETAIL_REPORT_YES:
            return "report 내부에서 Spam 등 버튼 클릭 시"
        case .CLICK_DETAIL_REPORT_NO:
            return "report 내부에서 cancel 버튼 클릭 시"
            
            // Edit
        case .VIEW_EDIT:
            return "edit 화면"
        case .SCROLL_EDIT:
            return "edit 화면 스크롤 시"
        case .CLICK_EDIT_PROFILE_EDIT:
            return "상단 profile edit 버튼 선택 시"
        case .CLICK_EDIT_PREVIEW:
            return "edit 화면에서 preview 버튼 선택 시"
        case .CLICK_EDIT_NAME:
            return "name 텍스트 필드 선택 시"
        case .CLICK_EDIT_PORTFOLIO:
            return "portfolio 버튼 선택 시"
        case .CLICK_EDIT_PORTFOLIO_DELETE:
            return "portfolio 사진 삭제 버튼 선택 시"
        case .CLICK_EDIT_TALENT:
            return "talent 수정 버튼 선택 시"
        case .CLICK_EDIT_DESCRIPTION:
            return "description 텍스트 필드 선택 시"
        case .CLICK_EDIT_PURPOSE:
            return "purpose 수정 버튼 선택 시"
        case .CLICK_EDIT_INSTA:
            return "instagram 버튼 선택 시"
        case .CLICK_EDIT_WEB:
            return "web 버튼 선택 시"
        case .CLICK_EDIT_SAVE:
            return "edit save 버튼 클릭 시"
        case .CLICK_EDIT_EDITSTART:
            return "edit start 버튼 클릭 시"
        case .VIEW_PREVIEW:
            return "preview 화면"
            
        case .CLICK_MATCH_CLOSE:
            return "매칭 화면에서 x 버튼 누를 때"
        case .CLICK_MATCH_MESSAGE:
            return "매칭 메세지 버튼 누를 때"
        case .CLICK_MATCH_SEND:
            return "메세지 보낼 때"

        case .VIEW_CHAT:
            return "채팅 화면"
        case .VIEW_EMPTY:
            return "empty 화면"
        case .SCROLL_CHAT:
            return "채팅 화면 스크롤 시"
        case .SCROLL_CHATROOM:
            return "채팅방 화면 스크롤 시"
        case .CLICK_CHAT:
            return "채팅 클릭 시"
        case .VIEW_CHATROOM:
            return "채팅방 뷰"
        case .CLICK_CHATROOM_PLUS:
            return "채팅방 + 버튼 클릭 시"
        case .CLICK_CHATROOM_SEND:
            return "채팅방 보내기 버튼 눌렀을 때"
        case .CLICK_CHATROOM_PROFILE:
            return "채팅방 화면 안에서 프로필을 눌렀을 떄"
        case .CLICK_CHATROOM_TRANS_ON:
            return "채팅방 번역 on"
        case .CLICK_CHATROOM_TRANS_OFF:
            return "채팅방 번역 off"
        case .CLICK_CHATROOM_TRANSLATE_CHOOSE:
            return "채팅방 번역할 언어 선택 시"
        case .CLICK_CHATROOM_TRANSLATE_LANGUAGE:
            return "채팅방 번역 언어 바꾸기"
        case .CLICK_CHATROOM_BACK:
            return "채팅방 뒤로가기 시"

        case .VIEW_INFO:
            return "info 화면"
        case .CLICK_INFO_HELP:
            return "Help & Support 버튼 눌렀을 때"
        case .CLICK_INFO_COMMUNITY:
            return "Community 버튼 눌렀을 때"
        case .CLICK_INFO_PRIVACY:
            return "Privacy 버튼 눌렀을 때"
        case .CLICK_INFO_LOGOUT:
            return "로그아웃 시"
        case .CLICK_INFO_LOGOUT_YES:
            return "로그아웃 버튼 선택 후 yes 선택 시"
        case .CLICK_INFO_LOGOUT_NO:
            return "로그아웃 버튼 선택 후 no 선택 시"
        case .CLICK_INFO_DELETE:
            return "계정 삭제 버튼 눌렀을 때"
            
        case .CLICK_INFO_DELETE1_YES:
            return "계정 삭제 버튼 선택 후 첫번째 팝업에서 [Yes] 선택 시"
        case .CLICK_INFO_DELETE2_YES:
            return "계정 삭제 버튼 선택 후 두번째 팝업에서 [Delete] 선택 시"
        case .CLICK_INFO_DELETE1_NO:
            return "계정 삭제 버튼 선택 후 첫번째 팝업에서 [Not, yet] 선택 시"
        case .CLICK_INFO_DELETE2_NO:
            return "계정 삭제 버튼 선택 후 두번째 팝업에서 [Cancel] 선택 시"
            
        case .RECEIVE_PUSH:
            return "푸시 알림을 받을 때"
        case .CLICK_PUSH:
            return "푸시 알림을 클릭할 때"
        case .UPDATE_DEVICE_TOKEN:
            return "Device Token Update"
            
        default:
            return "unknown"
        }
    }
}
