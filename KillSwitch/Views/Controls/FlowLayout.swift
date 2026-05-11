//
//  FlowLayout.swift
//  KillSwitch
//
//  Created by UglyGeorge on 11.05.2026.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map {
            $0.map {
                $0.sizeThatFits(.unspecified).height
            }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing }
            
        return CGSize(
            width: proposal.width ?? 0,
            height: max(0, height - spacing))
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map {
                $0.sizeThatFits(.unspecified).height
            }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var x: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let width = subview.sizeThatFits(.unspecified).width
            
            if x + width > maxWidth, !rows[rows.endIndex - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.endIndex - 1].append(subview)
            x += width + spacing
        }
        
        return rows
    }
}
