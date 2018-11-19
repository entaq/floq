/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.

 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import IGListKit
import Firebase

final class PhotoSection: ListSectionController {
    
    private var cliq: FLCliqItem?
    var storageRef: StorageReference!
    
    override init() {
        super.init()
        storageRef = Storage.storage().reference()
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width  ?? 0
        let height: CGFloat = CGFloat(index == 0 ? 200 : 2)
        return CGSize(width: width , height: height)
    }
    

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        if let cell = collectionContext?.dequeueReusableCell(withNibName: "cliqCells", bundle: Bundle.main, for: self, at: index) as? CliqsCell {
            let reference = storageRef.child(cliq?.photoItem.photoID ?? "")
            cell.configureView(reference: reference, title: cliq!.cliqname, creator:cliq!.photoItem.user)
            return cell
        }
        return ImageCell()
    }
    
    override func didUpdate(to object: Any) {
        self.cliq = object as? FLCliqItem
    }
}
