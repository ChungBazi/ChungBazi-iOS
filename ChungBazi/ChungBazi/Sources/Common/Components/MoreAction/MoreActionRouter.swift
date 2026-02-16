//
//  MoreActionRouter.swift
//  ChungBazi
//
//  Created by 신호연 on 9/18/25.
//

import UIKit

final class MoreActionRouter {
    static func present(
        in hostView: UIView,
        for entity: MoreEntity,
        onSelect: @escaping (MoreAction, MoreEntity) -> Void
    ) {
        let items = buildItems(for: entity)
        let sheetItems = items.map { BottomSheetView.Item(title: $0.title, textColor: $0.color) }

        weak var sheetRef: BottomSheetView?
        sheetRef = BottomSheetView.present(in: hostView, items: sheetItems) { index, _ in
            guard items.indices.contains(index) else { return }

            DispatchQueue.main.async {
                sheetRef?.dismiss()
            }
            
            onSelect(items[index].action, entity)
        }
    }

    private static func buildItems(for entity: MoreEntity) -> [MoreActionItem] {
        if entity.mine {
            return [ MoreActionItem(title: "삭제하기", color: AppColor.buttonAccent, action: .delete) ]
        } else {
            return [
                //                MoreActionItem(title: "대댓글 알람 켜기", color: AppColor.gray800,      action: .toggleReplyAlarm),
//                MoreActionItem(title: "쪽지 보내기",     color: AppColor.gray800,      action: .sendMessage),
                MoreActionItem(title: "신고하기",        color: AppColor.buttonAccent, action: .report),
                MoreActionItem(title: "차단하기",        color: AppColor.buttonAccent, action: .block)
            ]
        }
    }
}
