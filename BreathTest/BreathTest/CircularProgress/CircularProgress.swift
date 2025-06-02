import SwiftUI

public struct CircularProgressView: View {
    
    //Constant Var
    
    let diameterConstant:CGFloat = UIScreen.main.bounds.height * 0.35
    let fontBreath:Font = Font.system(size: UIScreen.main.bounds.height > 1000 ? UIScreen.main.bounds.height * CGFloat(0.12) : UIScreen.main.bounds.height * CGFloat(0.10), weight: .bold, design: .monospaced)
    let fontOne:Font = Font.system(size: UIScreen.main.bounds.height > 1000 ? UIScreen.main.bounds.height * CGFloat(0.07) : UIScreen.main.bounds.height * CGFloat(0.06), weight: .bold, design: .monospaced)
    let fontTwo:Font = Font.system(size: UIScreen.main.bounds.height * CGFloat(0.03), weight: .bold, design: .monospaced)
    let lineWidth:CGFloat = UIScreen.main.bounds.height * 0.02
    
    
    //MARK: Required variables
    var count: Int
    var total: Int
    var progress: CGFloat
    var breathLabel: Bool
    
    //MARK: Optional variables
    //fontOne for the current value text and fontTwo for the total value text in the centre.
   // var fontOne: Font
   // var fontTwo: Font

    //colorOne for the current value text and colorTwo for the total value text in the centre.
    var colorOne: Color
    var colorTwo: Color

    //The fill variable is used to choose the gradient inside the progress bar
    var fill: AnyShapeStyle
    //The lineWidth variable is used to choose the width of the progress bar (Not the enter view)
   // var lineWidth: CGFloat
    //The lineCap variable is used to choose the line caps at the end of the progress bar
    var lineCap: CGLineCap
    //Choose whether the text in the centre is shown.
    var showText: Bool
    //Choose whether the bottom text in the centre of the progress bar is shown.
    var showBottomText: Bool
    
    
    //MARK: Init
    //Declared to allow view access the package
    //Also sets defaults for optional variables
    public init(count: Int,
                total: Int,
                progress: CGFloat,
               // fontOne: Font = Font.system(size: 90, weight: .bold, design: .monospaced),
                //fontTwo: Font = Font.system(size: 25, weight: .bold, design: .monospaced),
                colorOne: Color = Color.primary,
                colorTwo: Color = Color.gray,
                fill: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .top, endPoint: .bottom),
               // lineWidth: CGFloat = 15.0,//25.0,
                lineCap: CGLineCap = CGLineCap.round,
                showText: Bool = true,
                showBottomText: Bool = true,
                breathLabel: Bool) {

        self.count = count
        self.total = total
        self.progress = progress
       // self.fontOne = fontOne
        //self.fontTwo = fontTwo
        self.colorOne = colorOne
        self.colorTwo = colorTwo
        self.fill = AnyShapeStyle(fill)
       // self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.showText = showText
        self.showBottomText = showBottomText
        self.breathLabel = breathLabel
    }
    
    public init(count: Int,
                total: Int,
                progress: CGFloat,
                //fontOne: Font = Font.system(size: 90, weight: .bold, design: .monospaced),
                //fontTwo: Font = Font.system(size: 25, weight: .bold, design: .monospaced),
                colorOne: Color = Color.primary,
                colorTwo: Color = Color.gray,
                fill: AngularGradient,
                //lineWidth: CGFloat = 15.0, //25.0,
                lineCap: CGLineCap = CGLineCap.round,
                showText: Bool = true,
                showBottomText: Bool = true,
                breathLabel: Bool) {

        self.count = count
        self.total = total
        self.progress = progress
       // self.fontOne = fontOne
       // self.fontTwo = fontTwo
        self.colorOne = colorOne
        self.colorTwo = colorTwo
        self.fill = AnyShapeStyle(fill)
       // self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.showText = showText
        self.showBottomText = showBottomText
        self.breathLabel = breathLabel
    }

 
    
    //MARK: View
    public var body: some View {
        
            ZStack{
                //Background line for progress
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .opacity(0.3)
                    .foregroundColor(Color.secondary)
                
                //Trimmed circle to represent progress
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(fill ,style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                if showText {
                    //Text at the centre
                    VStack {
                        //Text for current value
                        Text(displayText(breathLabel: breathLabel))
                            .font(breathLabel ? fontBreath: fontOne)
                            .foregroundColor(colorOne)
                        if showBottomText{
                            //Text for total value
                            Text(bottomDisplayText(breathLabel: breathLabel))
                                .font(fontTwo)
                                .foregroundColor(colorTwo)
                        }
                    }
                }
            }
        
        .onAppear {
//            print(UIScreen.main.bounds.height)
//            print(diameterConstant)
//
//            print(lineWidth)
            
        }

        .frame(height: diameterConstant)
    }
    
    func displayText(breathLabel: Bool) -> String {
        if breathLabel {
            return "\(count)"
        } else {
            return formatTime(time: Double(count))
        }
    }
    
    func bottomDisplayText(breathLabel: Bool) -> String {
        if breathLabel {
            return "Breaths"
        } else {
            if count >= 3600 {
                return "Hrs:Min:Sec"
            } else {
                return "Min:Sec"
            }
        }       
    }
    
    func formatTime(time : Double) -> String {
        
        if count >= 3600 {
            
            let hrs = Int(time) / 3600
            let min = Int(time - Double(hrs * 3600)) / 60
            let sec = Int(time - Double(hrs * 3600)) % 60
            return String(format:"%0i:%02i:%02i", hrs,min, sec)
            
        } else if count < 3600 && time >= 600 {
            
            let min = Int(time) / 60
            let sec = Int(time) % 60
            return String(format:"%02i:%02i", min, sec)
            
        } else {
            
            let min = Int(time) / 60
            let sec = Int(time) % 60
            return String(format:"%0i:%02i", min, sec)
            
        }
    }
    
}

/*
 func formatTime(time : Double) -> String {
     
     if time >= 3600 {
         
         let hrs = Int(time) / 3600
         let min = Int(time - Double(hrs * 3600)) / 60
         let sec = Int(time - Double(hrs * 3600)) % 60
         return String(format:"%0i:%02i:%02i", hrs,min, sec)
         
     } else if time < 3600 && time >= 600 {
         
         let min = Int(time) / 60
         let sec = Int(time) % 60
         return String(format:"%02i:%02i", min, sec)
         
     } else {
         
         let min = Int(time) / 60
         let sec = Int(time) % 60
         return String(format:"%0i:%02i", min, sec)
         
     }
     
 }
 
 
 */
