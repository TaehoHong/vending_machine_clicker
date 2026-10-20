import Foundation
import CoreText
import CoreGraphics

let fontURL=URL(fileURLWithPath:CommandLine.arguments[1])
let inputURL=URL(fileURLWithPath:CommandLine.arguments[2])
let outputURL=URL(fileURLWithPath:CommandLine.arguments[3])
let source=try JSONSerialization.jsonObject(with:Data(contentsOf:inputURL)) as! [String:Any]
let items=(source["navigation"] as! [[String:Any]])+(source["common"] as! [[String:Any]])
let labels=Set(items.compactMap{$0["label"] as? String}.filter{!$0.isEmpty})
let font=CTFontCreateWithGraphicsFont(CGFont(CGDataProvider(url:fontURL as CFURL)!)!,28,nil,nil)
func n(_ v:CGFloat)->String {String(format:"%.4f",Double(v))}
var result:[String:Any]=[:]
for label in labels.sorted(){
 let chars=Array(label.utf16)
 var glyphs=[CGGlyph](repeating:0,count:chars.count)
 CTFontGetGlyphsForCharacters(font,chars,&glyphs,chars.count)
 var advances=[CGSize](repeating:.zero,count:chars.count)
 CTFontGetAdvancesForGlyphs(font,.horizontal,glyphs,&advances,glyphs.count)
 var x:CGFloat=0
 var d=""
 for (i,glyph) in glyphs.enumerated(){
  if let path=CTFontCreatePathForGlyph(font,glyph,nil){path.applyWithBlock{ptr in
   let e=ptr.pointee
   func p(_ i:Int)->String {let pt=e.points[i];return "\(n(pt.x+x)) \(n(-pt.y))"}
   switch e.type{
    case .moveToPoint:d += "M"+p(0)
    case .addLineToPoint:d += "L"+p(0)
    case .addQuadCurveToPoint:d += "Q"+p(0)+" "+p(1)
    case .addCurveToPoint:d += "C"+p(0)+" "+p(1)+" "+p(2)
    case .closeSubpath:d += "Z"
    @unknown default:break
   }
  }}
  x += advances[i].width
 }
 result[label]=["width":x,"path":d]
}
try JSONSerialization.data(withJSONObject:result,options:[.prettyPrinted,.sortedKeys]).write(to:outputURL)
print("Generated \(result.count) original-font labels.")
