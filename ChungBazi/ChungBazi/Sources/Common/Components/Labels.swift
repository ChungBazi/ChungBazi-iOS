//
//  Labels.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit

class BaseTitleLabel: UILabel {
    init(text: String, font: UIFont, textColor: UIColor = .gray800) {
        super.init(frame: .zero)
        self.text = text
        self.font = font
        self.textColor = textColor
        self.numberOfLines = 0
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        self.addCharacterSpacing(-0.32) //FIXME: 자간 변경
        if let text = self.text, text.contains("\n") || numberOfLines > 1 {
            self.setLineSpacing(ratio: 1.4)
        } else {
            self.setLineSpacing(ratio: 0)
        }
    }
}

class H32_SB: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdSemiBoldFont(ofSize: 32), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class H28_SB: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdSemiBoldFont(ofSize: 28), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class H24_SB: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdSemiBoldFont(ofSize: 24), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class H24_M: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdMediumFont(ofSize: 24), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class T20_SB: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdSemiBoldFont(ofSize: 20), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class T20_M: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdMediumFont(ofSize: 20), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class B16_SB: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdSemiBoldFont(ofSize: 16), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class B16_M: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdMediumFont(ofSize: 16), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class B12_M: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdMediumFont(ofSize: 12), textColor: textColor)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BTN16_M: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdMediumFont(ofSize: 16), textColor: textColor)
        self.addCharacterSpacing(0.01)
        self.setLineSpacing(ratio: 1.4)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BTN14_SB: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdSemiBoldFont(ofSize: 14), textColor: textColor)
        self.addCharacterSpacing(0.01)
        self.setLineSpacing(ratio: 1.4)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BTN14_M: BaseTitleLabel {
    init(text: String, textColor: UIColor = .black) {
        super.init(text: text, font: .ptdMediumFont(ofSize: 14), textColor: textColor)
        self.addCharacterSpacing(0.01)
        self.setLineSpacing(ratio: 1.4)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
