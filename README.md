# 청바지
> 

## 🍎 Developers

| <img src="https://avatars.githubusercontent.com/u/89966409?v=4" width=120px alt="신호연"/>  | <img src="" width=120px alt="엄민서"/>  | <img src="https://avatars.githubusercontent.com/u/128601891?v=4" width=120px alt="이현주"/>  | 
| :-----: | :-----: | :-----: |
| [신호연](https://github.com/fnfn0901) | [엄민서](https://github.com/seo1v)  | [이현주](https://github.com/dlguszoo)  |

## 🏁 Getting Started
### **Prerequisites**
  - **MacOS**: Any version (Latest version recommended)
  - **Xcode**: Latest version
  - **Simulator**: iPhone 13 mini 
    
### **Repository Clone**
  ```bash
git clone https://github.com/ChungBazi/ChungBazi-iOS.git
cd ChungBazi-iOS
  ```

### **Setup**
   1. Open the `Drink-EG.xcodeproj` file in Xcode.
   2. Verify the simulator version you want to use.
   3. Build and run the project. Please note that Kakao Login is currently unavailable.

## 🔧 Stack
- UIKit
- Snapkit
- Then
- Moya
- KakaoOpenSDK
- FSCalendar

## 💻 Code Convention

[🔗 Code Convention](https://spiced-darkness-392.notion.site/Code-Convention-1778ec4cbe5080c19d94d5a153e42c28?pvs=74)
> StyleShare 의 Swift Style Guide 를 기본으로 작성되었습니다.
```
1. 성능 최적화와 위해 더 이상 상속되지 않을 class 에는 꼭 final 키워드를 붙입니다.
2. 안전성을 위해 class 에서 사용되는 property는 모두 private로 선언합니다.
3. 명시성을 위해 약어와 생략을 지양합니다.
   VC -> ViewController
   TVC -> TableViewCell
4. 빠른 확인을 위해 Global위치에 함수를 만든다면, 퀵 헬프 주석을 답니다.
5. 런타임 크래시를 방지하기 위해 강제 언래핑을 사용하지 않습니다.
```

## 💻 Git Convention

[🔗 Git Convention](https://spiced-darkness-392.notion.site/Git-Convention-1778ec4cbe508096b7b5f918f0662299)

- `dev 브랜치` 개발 작업 브랜치
- `main 브랜치` 릴리즈 버전 관리 브랜치

```
1. 작업할 내용에 대해서 이슈를 생성한다.
2. 나의 로컬에서 develop 브랜치가 최신화 되어있는지 확인한다.
3. develop 브랜치에서 새로운 이슈 브랜치를 생성한다 [커밋타입/#이슈번호]
4. 만든 브랜치에서 작업한다.
5. 커밋은 기능마다 쪼개서 작성한다.
6. 작업 완료 후, 에러가 없는지 확인한 후 push 한다.
7. 코드리뷰 후 수정사항 반영한 뒤, develop 브랜치에 merge 한다.
```

## 💻 Commit Convention

[🔗 Commit Convention](https://spiced-darkness-392.notion.site/Commit-Convention-1778ec4cbe508021941ae2973ea1fc15)
> StyleShare 의 Swift Style Guide 를 기본으로 작성되었습니다.
```
1. #이슈번호 <type>: <description> 형식으로 작성한다.
2. 정해진 커밋 타입(feat, fix, style ...)으로 작성한다.
3. 제목은 간단히 작성하며, 필요한 경우 본문에 변경 이유와 설명을 추가한다.
4. 커밋은 기능 단위로 나눠서 작성하고 이슈 번호를 포함한다.
```


