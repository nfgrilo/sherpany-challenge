//
//  PostAlbumCollectionViewFlowLayout.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 17/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostAlbumCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // need to work on a copy of the original attributes, otherwise some issues may occur
        guard let attrs = (super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes }) else {
            return nil
        }
        
        // top align items
        var lineCenterY: CGFloat = 0
        var inlineItems: [UICollectionViewLayoutAttributes] = []
        for item in attrs where item.representedElementCategory == .cell {
            let itemCenterY = item.frame.midY
            // new line!
            if abs(itemCenterY - lineCenterY) > CGFloat.ulpOfOne {
                // align items in array (on same line)
                layout(inlineItems)
                // remember new Y center
                lineCenterY = itemCenterY
                // and clear items in array
                inlineItems.removeAll()
            }
            inlineItems.append(item)
        }
        
        // align last line
        layout(inlineItems)
        
        return attrs
    }
    
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
    
    private func layout(_ inlineItems: [UICollectionViewLayoutAttributes]) {
        guard inlineItems.count > 0 else { return }
        
        // compute item spacing
        let spacing = (collectionViewContentSize.width - inlineItems.compactMap { return $0.frame.width }.reduce(0, +)) / CGFloat(inlineItems.count + 1)
        
        // find tallest item
        guard let tallestItem = (inlineItems.sorted { return $0.frame.height < $1.frame.height }).last else { return }
        
        // align all to highest Y  &  distribute horizontal spacing equally
        var lastX: CGFloat = 0
        for item in inlineItems {
            let horizAdjustment: CGFloat = (lastX + spacing) - item.frame.minX
            let vertAdjustment = tallestItem.frame.minY - item.frame.minY
            item.frame = item.frame.offsetBy(dx: horizAdjustment, dy: vertAdjustment)
            
            lastX = item.frame.maxX
        }
    }
    
}
