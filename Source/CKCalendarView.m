//
// Copyright (c) 2012 Jason Kozemczak
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CKCalendarView.h"

#define BUTTON_MARGIN 6
#define CALENDAR_MARGIN 0
#define TOP_HEIGHT 23
#define DAYS_HEADER_HEIGHT 19
#define DEFAULT_CELL_WIDTH 43
#define DEFAULT_CELL_HEIGHT 33
#define CELL_BORDER_WIDTH 0
#define MARKER_COLOR [UIColor colorWithRed:0.094118 green:0.474510 blue:0.788235 alpha:1]
#define ARROW_BUTTON_WIDTH 50
#define ARROW_BUTTON_HEIGHT 18

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef enum {
    CKDateButtonStyleNotCurrentMonth,
    CKDateButtonStyleCurrentMonth,
    CKDateButtonStyleToday,
    CKDateButtonStyleSelected,
} CKDateButtonStyle;

typedef enum {
    CKDateButtonPositionLeft,
    CKDateButtonPositionCenter,
    CKDateButtonPositionRight
} CKDateButtonPosition;

@interface CKDateButton ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic) CKDateButtonStyle buttonStyle;
@property (nonatomic) CKDateButtonPosition buttonPosition;
@property (nonatomic, strong) UIImage *markerImage;
@property (nonatomic, strong) UIView *markerContainer;

@end

@implementation CKDateButton

- (void)setDate:(NSDate *)date {
    _date = date;
    NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSMutableString *dateString = [NSMutableString stringWithFormat:@"%d", comps.day];
    if (dateString.length == 1) {
        dateString = [NSMutableString stringWithFormat:@"  %@", dateString];
    }
    [self setTitle:dateString forState:UIControlStateNormal];
}

- (void)setEventCount:(NSInteger)eventCount
{
    _eventCount = eventCount;
    
    if (self.markerContainer != nil) {
        [self.markerContainer removeFromSuperview];
        self.markerContainer = nil;
    }
    if (eventCount > 0) {
        UIView *markerContainer = [[UIView alloc] initWithFrame:CGRectMake(2.5, 3.0, 39.0, 5.0)];
        markerContainer.backgroundColor = [UIColor clearColor];
        self.markerContainer = markerContainer;
        [self addSubview:self.markerContainer];
        
        if (eventCount < 8) {
            [self drawMarkers];
        } else if (eventCount > 7) {
            [self drawMarkerBar];
        }
    }
}

- (void)drawMarkers
{
    if (!self.markerImage) {
        UIImage *markerImage = [self markerImageWithColor:MARKER_COLOR];
        self.markerImage = markerImage;
    }
    for (NSInteger i = 0; i < self.eventCount; i++) {
        UIImageView *markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 5.5, 0, 4.5, 4.5)];
        markerImageView.image = self.markerImage;
        [self.markerContainer addSubview:markerImageView];
    }
}

- (void)drawMarkerBar
{
    UIImageView *markerBarImageView = [[UIImageView alloc] initWithImage:[self markerBarImageWithColor:MARKER_COLOR]];
    [self.markerContainer addSubview:markerBarImageView];
}

- (UIImage *)markerImageWithColor:(UIColor *)color
{
    CGSize size = CGSizeMake(5.0, 5.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [color setFill];
    [path fill];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)markerBarImageWithColor:(UIColor *)color
{
    CGFloat width = 38.0;
    CGFloat height = 5.0;
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(height / 2, 0.0)];
    [path addLineToPoint:CGPointMake(width - (height / 2), 0.0)];
    [path addArcWithCenter:CGPointMake(width - (height / 2), height / 2) radius:(height / 2) startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    [path addLineToPoint:CGPointMake(height / 2, height)];
    [path addArcWithCenter:CGPointMake(height / 2, height / 2) radius:(height / 2) startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    
    [color setFill];
    [path fill];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (void)configureWithStyle:(CKDateButtonStyle)style position:(CKDateButtonPosition)position
{
    self.buttonStyle = style;
    self.buttonPosition = position;
    
    switch (self.buttonStyle) {
        case CKDateButtonStyleNotCurrentMonth:
            self.backgroundColor = [UIColor colorWithRed:0.878431 green:0.890196 blue:0.894118 alpha:1];
            [self setTitleColor:[UIColor colorWithRed:0.674510 green:0.690196 blue:0.694118 alpha:1] forState:UIControlStateNormal];
            break;
        case CKDateButtonStyleCurrentMonth:
            self.backgroundColor = [UIColor colorWithRed:0.878431 green:0.890196 blue:0.894118 alpha:1];
            [self setTitleColor:[UIColor colorWithRed:0.439216 green:0.450980 blue:0.454902 alpha:1] forState:UIControlStateNormal];
            break;
        case CKDateButtonStyleToday:
            self.backgroundColor = [UIColor colorWithRed:0.796079 green:0.803922 blue:0.807843 alpha:1];
            [self setTitleColor:[UIColor colorWithRed:0.058824 green:0.058824 blue:0.058824 alpha:1] forState:UIControlStateNormal];
            break;
        case CKDateButtonStyleSelected:
            self.backgroundColor = [UIColor whiteColor];
            [self setTitleColor:[UIColor colorWithRed:0.058824 green:0.058824 blue:0.058824 alpha:1] forState:UIControlStateNormal];
            break;
    }
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(15.0f, 18.0f, 0.0f, 0.0f)];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    switch (self.buttonStyle) {
        case CKDateButtonStyleToday: [self drawTodayStyleBorders]; break;
        case CKDateButtonStyleSelected: [self drawSelectedStyleBorders]; break;
        default: [self drawDefaultBorders];
    }
}

- (void)drawDefaultBorders
{
    UIBezierPath *lightBorderPath = [UIBezierPath bezierPath];
    [lightBorderPath moveToPoint:CGPointMake(0, 0)];
    [lightBorderPath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
    UIColor *lightBorderColor = [UIColor colorWithRed:0.952941 green:0.956863 blue:0.960784 alpha:1];
    [lightBorderPath setLineWidth:2.0];
    
    UIBezierPath *darkBorderPath = [UIBezierPath bezierPath];
    UIColor *darkBorderColor = [UIColor colorWithRed:0.729412 green:0.745098 blue:0.745098 alpha:1];
    if (self.buttonPosition != CKDateButtonPositionRight) {
        [darkBorderPath moveToPoint:CGPointMake(self.frame.size.width, 1)];
        [darkBorderPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    } else {
        [darkBorderPath moveToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    }
    [darkBorderPath addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [darkBorderPath setLineWidth:2.0];
    [darkBorderColor setStroke];
    [darkBorderPath stroke];
    
    if (self.buttonPosition != CKDateButtonPositionLeft) {
        [lightBorderPath moveToPoint:CGPointMake(0, self.frame.size.height - 1)];
        [lightBorderPath addLineToPoint:CGPointMake(0, 0)];
    }
    
    [lightBorderColor setStroke];
    [lightBorderPath stroke];
}

- (void)drawTodayStyleBorders
{
    UIColor *frameColor = [UIColor colorWithRed:0.494118 green:0.494118 blue:0.494118 alpha:1];
    [self drawFrameWithLineWidth:2.0 color:frameColor];
    
    UIColor *shadow1Color = [UIColor colorWithRed:0.588235 green:0.592157 blue:0.592157 alpha:1];
    UIColor *shadow2Color = [UIColor colorWithRed:0.725490 green:0.733333 blue:0.733333 alpha:1];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath setLineWidth:0.5];
    
    [shadowPath moveToPoint:CGPointMake(1, 1)];
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width - 1, 1)];
    [shadow1Color setStroke];
    [shadowPath stroke];
    
    [shadowPath moveToPoint:CGPointMake(1, 1.5)];
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width - 1, 1.5)];
    [shadow2Color setStroke];
    [shadowPath stroke];
}

- (void)drawSelectedStyleBorders
{
    UIColor *color = [UIColor colorWithRed:0.011765 green:0.423529 blue:0.631373 alpha:1];
    [self drawFrameWithLineWidth:5.0 color:color];
}

- (void)drawFrameWithLineWidth:(CGFloat)lineWidth color:(UIColor *)color
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [path setLineWidth:lineWidth];
    [color setStroke];
    [path stroke];
}

@end


typedef enum {
    CKArrowButtonDirectionLeft,
    CKArrowButtonDirectionRight
} CKArrowButtonDirection;

@interface CKArrowButton : UIButton

@property (nonatomic) CKArrowButtonDirection direction;
@property (nonatomic) BOOL useGradient;
@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, strong) UIColor *topColor;
@property (nonatomic, strong) UIColor *bottomColor;

@end

@implementation CKArrowButton

- (id)initWithDirection:(CKArrowButtonDirection)direction topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor height:(CGFloat)height width:(CGFloat)width
{
    self = [super init];
    if (self) {
        self.direction = direction;
        self.useGradient = YES;
        self.topColor = topColor;
        self.bottomColor = bottomColor;
        [self setImage:[self arrowImageWithHeight:height width:width] forState:UIControlStateNormal];
    }
    return self;
}

- (id)initWithDirection:(CKArrowButtonDirection)direction color:(UIColor *)color height:(CGFloat)height width:(CGFloat)width
{
    self = [super init];
    if (self) {
        self.direction = direction;
        self.arrowColor = color;
        [self setImage:[self arrowImageWithHeight:height width:width] forState:UIControlStateNormal];
    }
    return self;
}

- (UIImage *)arrowImageWithHeight:(CGFloat)height width:(CGFloat)width
{
    CGFloat arrowWidth = floorf(height * 0.72);
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (self.direction == CKArrowButtonDirectionRight) {
        [path moveToPoint:CGPointMake(width - arrowWidth, 0)];
        [path addLineToPoint:CGPointMake(width, height / 2.0f)];
        [path addLineToPoint:CGPointMake(width - arrowWidth, height)];
    } else {
        [path moveToPoint:CGPointMake(arrowWidth, 0)];
        [path addLineToPoint:CGPointMake(0, height / 2.0f)];
        [path addLineToPoint:CGPointMake(arrowWidth, height)];
    }
    [path closePath];
    
    if (self.useGradient) {
        [path addClip];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        CGColorRef colors[] = { self.topColor.CGColor, self.bottomColor.CGColor };
        CFArrayRef colorsArr = CFArrayCreate(NULL, (const void **)colors, sizeof(colors) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArr, locations);
        
        CGPoint startPoint = CGPointMake(0, 0);
        CGPoint endPoint = CGPointMake(0, height);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    } else {
        [self.arrowColor setFill];
        [path fill];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end


@interface CKCalendarView ()

@property(nonatomic, strong) UIButton *titleLabelButton;
@property(nonatomic, strong) CKArrowButton *prevButton;
@property(nonatomic, strong) CKArrowButton *nextButton;
@property(nonatomic, strong) UIView *calendarContainer;
@property(nonatomic, strong) UIImageView *daysHeader;
@property(nonatomic, strong) NSArray *dayOfWeekLabels;
@property(nonatomic, strong) NSMutableArray *dateButtons;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDate *monthShowing;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSCalendar *calendar;
@property(nonatomic, assign) CGFloat cellWidth;
@property(nonatomic, assign) CGFloat cellHeight;

@end

@implementation CKCalendarView

@dynamic locale;

- (id)init {
    return [self initWithStartDay:startSunday];
}

- (id)initWithStartDay:(CKCalendarStartDay)firstDay {
    return [self initWithStartDay:firstDay frame:CGRectMake(0, 0, 301, 320)];
}

- (void)_init:(CKCalendarStartDay)firstDay {
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];
    
    self.cellWidth = DEFAULT_CELL_WIDTH;
    self.cellHeight = DEFAULT_CELL_HEIGHT;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateFormatter.dateFormat = @"LLLL yyyy";
    
    self.calendarStartDay = firstDay;
    self.onlyShowCurrentMonth = YES;
    self.adaptHeightToNumberOfWeeksInMonth = YES;
    
    [self setupHeader];
    
    // THE CALENDAR ITSELF
    UIView *calendarContainer = [[UIView alloc] initWithFrame:CGRectZero];
    calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    calendarContainer.clipsToBounds = YES;
    [self addSubview:calendarContainer];
    self.calendarContainer = calendarContainer;
    
    UIImageView *daysHeader = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.calendarContainer addSubview:daysHeader];
    self.daysHeader = daysHeader;
    
    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
        dayOfWeekLabel.backgroundColor = [UIColor clearColor];
        [labels addObject:dayOfWeekLabel];
        [self.calendarContainer addSubview:dayOfWeekLabel];
    }
    self.dayOfWeekLabels = labels;
    [self updateDayOfWeekLabels];
    
    // at most we'll need 42 buttons, so let's just bite the bullet and make them now...
    NSMutableArray *dateButtons = [NSMutableArray array];
    for (NSInteger i = 1; i <= 42; i++) {
        CKDateButton *dateButton = [CKDateButton buttonWithType:UIButtonTypeCustom];
        dateButton.calendar = self.calendar;
        [dateButton addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [dateButtons addObject:dateButton];
    }
    self.dateButtons = dateButtons;
    
    // initialize the thing
    self.monthShowing = [NSDate date];
    [self setDefaultStyle];
    
    [self layoutSubviews]; // TODO: this is a hack to get the first month to show properly
}

- (UIImage *)daysHeaderBackgroundImage
{
    CGFloat width = self.calendarContainer.frame.size.width;
    CGSize size = CGSizeMake(width, DAYS_HEADER_HEIGHT);
    
    UIColor *backgroundFillColor = [UIColor colorWithRed:0.603922 green:0.611765 blue:0.611765 alpha:1];
    UIColor *darkStrokeColor = [UIColor colorWithRed:0.313726 green:0.309804 blue:0.313726 alpha:1];
    UIColor *lightStrokeColor = [UIColor colorWithRed:0.721569 green:0.729412 blue:0.729412 alpha:1];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGRect backgroundRect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:backgroundRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    [backgroundFillColor setFill];
    [backgroundPath fill];
    
    CGRect bottomBorderRect = CGRectMake(0, DAYS_HEADER_HEIGHT - 1, width, 1);
    UIBezierPath *bottomBorderPath = [UIBezierPath bezierPathWithRect:bottomBorderRect];
    [darkStrokeColor setFill];
    [bottomBorderPath fill];
    
    for (int i = 1; i < 7; i++) {
        NSInteger x = i * DEFAULT_CELL_WIDTH;
        CGRect darkStrokeRect = CGRectMake(x - 1, 0, 1, DAYS_HEADER_HEIGHT);
        UIBezierPath *darkStrokePath = [UIBezierPath bezierPathWithRect:darkStrokeRect];
        [darkStrokeColor setFill];
        [darkStrokePath fill];
        
        CGRect lightStrokeRect = CGRectMake(x, 0, 1, DAYS_HEADER_HEIGHT - 1);
        UIBezierPath *lightStrokePath = [UIBezierPath bezierPathWithRect:lightStrokeRect];
        [lightStrokeColor setFill];
        [lightStrokePath fill];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (void)setupHeader
{
    UIButton *titleLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleLabelButton.backgroundColor = [UIColor clearColor];
    titleLabelButton.showsTouchWhenHighlighted = YES;
    titleLabelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabelButton.titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabelButton addTarget:self action:@selector(selectToday) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:titleLabelButton];
    self.titleLabelButton = titleLabelButton;
    
    UIColor *topColor = [UIColor colorWithRed:0.270588 green:0.682353 blue:0.968628 alpha:1];
    UIColor *bottomColor = [UIColor colorWithRed:0 green:0.466667 blue:0.792157 alpha:1];
    
    CKArrowButton *prevButton = [[CKArrowButton alloc] initWithDirection:CKArrowButtonDirectionLeft topColor:topColor bottomColor:bottomColor height:ARROW_BUTTON_HEIGHT width:ARROW_BUTTON_WIDTH];
    [prevButton addTarget:self action:@selector(moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevButton];
    self.prevButton = prevButton;
    
    CKArrowButton *nextButton = [[CKArrowButton alloc] initWithDirection:CKArrowButtonDirectionRight topColor:topColor bottomColor:bottomColor height:ARROW_BUTTON_HEIGHT width:ARROW_BUTTON_WIDTH];
    [nextButton addTarget:self action:@selector(moveCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    self.nextButton = nextButton;
}

- (id)initWithStartDay:(CKCalendarStartDay)firstDay frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init:firstDay];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithStartDay:startSunday frame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init:startSunday];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat containerWidth = self.bounds.size.width - (CALENDAR_MARGIN * 2);
    self.cellWidth = (floorf(containerWidth / 7.0)) - CELL_BORDER_WIDTH;
    
    NSInteger numberOfWeeksToShow = 6;
    if (self.adaptHeightToNumberOfWeeksInMonth) {
        numberOfWeeksToShow = [self numberOfWeeksInMonthContainingDate:self.monthShowing];
    }
    CGFloat containerHeight = (numberOfWeeksToShow * (self.cellHeight + CELL_BORDER_WIDTH) + DAYS_HEADER_HEIGHT);
    
    CGRect newFrame = self.frame;
    newFrame.size.height = containerHeight + CALENDAR_MARGIN + TOP_HEIGHT - 2;
    self.frame = newFrame;
    
    [self.titleLabelButton setTitle:[self.dateFormatter stringFromDate:_monthShowing] forState:UIControlStateNormal];
    self.titleLabelButton.frame = CGRectMake((self.bounds.size.width - 150) / 2, 0, 150, TOP_HEIGHT - 6);
    
    self.prevButton.frame = CGRectMake(BUTTON_MARGIN, 0, ARROW_BUTTON_WIDTH, ARROW_BUTTON_HEIGHT);
    self.nextButton.frame = CGRectMake(self.bounds.size.width - ARROW_BUTTON_WIDTH - BUTTON_MARGIN, 0, ARROW_BUTTON_WIDTH, ARROW_BUTTON_HEIGHT);
    
    self.calendarContainer.frame = CGRectMake(CALENDAR_MARGIN, CGRectGetMaxY(self.prevButton.frame) + 3, containerWidth, containerHeight);
    self.daysHeader.frame = CGRectMake(0, 0, self.calendarContainer.frame.size.width, DAYS_HEADER_HEIGHT);
    self.daysHeader.image = [self daysHeaderBackgroundImage];
    
    CGRect lastDayFrame = CGRectZero;
    for (UILabel *dayLabel in self.dayOfWeekLabels) {
        dayLabel.frame = CGRectMake(CGRectGetMaxX(lastDayFrame) + CELL_BORDER_WIDTH, lastDayFrame.origin.y, self.cellWidth, DAYS_HEADER_HEIGHT);
        lastDayFrame = dayLabel.frame;
    }
    
    [self removeAllDateButtons];
    
    NSDate *date = [self firstDayOfMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        while ([self placeInWeekForDate:date] != 0) {
            date = [self previousDay:date];
        }
    }
    
    NSDate *endDate = [self firstDayOfNextMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setWeek:numberOfWeeksToShow];
        endDate = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }
    
    NSDate *buttonDate = date;
    NSUInteger dateButtonOrder = 0;
    while ([buttonDate laterDate:endDate] != buttonDate) {
        CKDateButton *dateButton = [self.dateButtons objectAtIndex:dateButtonOrder];
        CKDateButtonPosition position;
        if (dateButtonOrder % 7 == 0) {
            position = CKDateButtonPositionLeft;
        } else if (dateButtonOrder % 7 == 6) {
            position = CKDateButtonPositionRight;
        } else {
            position = CKDateButtonPositionCenter;
        }
        
        dateButton.date = buttonDate;
        CGRect dateButtonFrame = [self calculateDayCellFrame:buttonDate];
        dateButton.frame = dateButtonFrame;
        
        if (!self.onlyShowCurrentMonth && [self compareByMonth:buttonDate toDate:self.monthShowing] != NSOrderedSame) {
            [dateButton configureWithStyle:CKDateButtonStyleNotCurrentMonth position:position];
        } else if (self.selectedDate && [self date:self.selectedDate isSameDayAsDate:buttonDate]) {
            [dateButton configureWithStyle:CKDateButtonStyleSelected position:position];;
        } else if ([self dateIsToday:buttonDate]) {
            [dateButton configureWithStyle:CKDateButtonStyleToday position:position];;
        } else {
            [dateButton configureWithStyle:CKDateButtonStyleCurrentMonth position:position];;
        }
        
        // let delegate do any additional configuration
        if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:configureDateButton:forDate:)]) {
            [self.delegate calendar:self configureDateButton:dateButton forDate:buttonDate];
        }
        
        [self.calendarContainer addSubview:dateButton];
        
        buttonDate = [self nextDay:buttonDate];
        dateButtonOrder++;
    }
    
    if ([self.delegate respondsToSelector:@selector(calendar:didLayoutInRect:)]) {
        [self.delegate calendar:self didLayoutInRect:self.frame];
    }
}

- (void)removeAllDateButtons
{
    for (CKDateButton *dateButton in self.dateButtons) {
        [dateButton removeFromSuperview];
    }
}

- (void)updateDayOfWeekLabels {
    NSArray *weekdays = [self.dateFormatter shortWeekdaySymbols];
    // adjust array depending on which weekday should be first
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }
    
    NSUInteger i = 0;
    for (NSString *day in weekdays) {
        [[self.dayOfWeekLabels objectAtIndex:i] setText:[day uppercaseString]];
        i++;
    }
}

- (void)setCalendarStartDay:(CKCalendarStartDay)calendarStartDay {
    _calendarStartDay = calendarStartDay;
    [self.calendar setFirstWeekday:self.calendarStartDay];
    [self updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (void)setLocale:(NSLocale *)locale {
    [self.dateFormatter setLocale:locale];
    [self updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (NSLocale *)locale {
    return self.dateFormatter.locale;
}

- (NSArray *)datesShowing {
    NSMutableArray *dates = [NSMutableArray array];
    // NOTE: these should already be in chronological order
    for (CKDateButton *dateButton in self.dateButtons) {
        if (dateButton.date) {
            [dates addObject:dateButton.date];
        }
    }
    return dates;
}

- (void)setMonthShowing:(NSDate *)aMonthShowing {
    _monthShowing = [self firstDayOfMonthContainingDate:aMonthShowing];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setOnlyShowCurrentMonth:(BOOL)onlyShowCurrentMonth {
    _onlyShowCurrentMonth = onlyShowCurrentMonth;
    [self setNeedsLayout];
}

- (void)setAdaptHeightToNumberOfWeeksInMonth:(BOOL)adaptHeightToNumberOfWeeksInMonth {
    _adaptHeightToNumberOfWeeksInMonth = adaptHeightToNumberOfWeeksInMonth;
    [self setNeedsLayout];
}

- (void)selectDate:(NSDate *)date makeVisible:(BOOL)visible {
    if (visible && date) {
        self.monthShowing = date;
    }
    
    NSMutableArray *datesToReload = [NSMutableArray array];
    if (self.selectedDate) {
        [datesToReload addObject:self.selectedDate];
    }
    if (date) {
        [datesToReload addObject:date];
    }
    self.selectedDate = date;
    [self reloadDates:datesToReload];
}

- (void)selectToday
{
    NSDate *today = [NSDate date];
    [self selectDate:today makeVisible:YES];
    [self.delegate calendar:self didSelectDate:today];
}

- (void)reloadData {
    self.selectedDate = nil;
    [self setNeedsLayout];
}

- (void)reloadDates:(NSArray *)dates {
    // TODO: only update the dates specified
    [self setNeedsLayout];
}

- (void)setDefaultStyle {
    self.backgroundColor = [UIColor clearColor];
    
    [self setTitleColor:[UIColor whiteColor]];
    [self setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0]];
    
    [self setDayOfWeekFont:[UIFont boldSystemFontOfSize:10.0]];
    [self setDayOfWeekTextColor:[UIColor colorWithRed:0.235294 green:0.243137 blue:0.243137 alpha:1]];
}

- (CGRect)calculateDayCellFrame:(NSDate *)date {
    NSInteger numberOfDaysSinceBeginningOfThisMonth = [self numberOfDaysFromDate:self.monthShowing toDate:date];
    NSInteger row = (numberOfDaysSinceBeginningOfThisMonth + [self placeInWeekForDate:self.monthShowing]) / 7;
	
    NSInteger placeInWeek = [self placeInWeekForDate:date];
    
    CGRect frame = CGRectMake(placeInWeek * (self.cellWidth + CELL_BORDER_WIDTH), (row * (self.cellHeight + CELL_BORDER_WIDTH)) + DAYS_HEADER_HEIGHT + CELL_BORDER_WIDTH, self.cellWidth, self.cellHeight);
    return frame;
}

- (void)moveCalendarToNextMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if ([self.delegate respondsToSelector:@selector(calendar:willChangeToMonth:)] && ![self.delegate calendar:self willChangeToMonth:newMonth]) {
        return;
    } else {
        self.monthShowing = newMonth;
        if ([self.delegate respondsToSelector:@selector(calendar:didChangeToMonth:)] ) {
            [self.delegate calendar:self didChangeToMonth:self.monthShowing];
        }
    }
}

- (void)moveCalendarToPreviousMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if ([self.delegate respondsToSelector:@selector(calendar:willChangeToMonth:)] && ![self.delegate calendar:self willChangeToMonth:newMonth]) {
        return;
    } else {
        self.monthShowing = newMonth;
        if ([self.delegate respondsToSelector:@selector(calendar:didChangeToMonth:)] ) {
            [self.delegate calendar:self didChangeToMonth:self.monthShowing];
        }
    }
}

- (void)moveCalendarToCurrentMonth
{
    self.monthShowing = [NSDate date];
}

- (void)dateButtonPressed:(id)sender {
    CKDateButton *dateButton = sender;
    NSDate *date = dateButton.date;
    if ([date isEqualToDate:self.selectedDate]) {
        // deselection..
        if ([self.delegate respondsToSelector:@selector(calendar:willDeselectDate:)] && ![self.delegate calendar:self willDeselectDate:date]) {
            return;
        }
        date = nil;
    } else if ([self.delegate respondsToSelector:@selector(calendar:willSelectDate:)] && ![self.delegate calendar:self willSelectDate:date]) {
        return;
    }
    
    [self selectDate:date makeVisible:YES];
    [self layoutIfNeeded]; // Use in place of setNeedsLayout to ensure that any container resizing is done before the delegate call below is made
    [self.delegate calendar:self didSelectDate:date];
}

#pragma mark - Theming getters/setters

- (void)setTitleFont:(UIFont *)font {
    self.titleLabelButton.titleLabel.font = font;
}
- (UIFont *)titleFont {
    return self.titleLabelButton.titleLabel.font;
}

- (void)setTitleColor:(UIColor *)color {
    self.titleLabelButton.titleLabel.textColor = color;
}
- (UIColor *)titleColor {
    return self.titleLabelButton.titleLabel.textColor;
}

- (void)setMonthButtonColor:(UIColor *)color {
    [self.prevButton setImage:[CKCalendarView imageNamed:@"left_arrow.png" withColor:color] forState:UIControlStateNormal];
    [self.nextButton setImage:[CKCalendarView imageNamed:@"right_arrow.png" withColor:color] forState:UIControlStateNormal];
}

- (void)setInnerBorderColor:(UIColor *)color {
    self.calendarContainer.layer.borderColor = color.CGColor;
}

- (void)setDayOfWeekFont:(UIFont *)font {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.font = font;
    }
}
- (UIFont *)dayOfWeekFont {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).font : nil;
}

- (void)setDayOfWeekTextColor:(UIColor *)color {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.textColor = color;
    }
}
- (UIColor *)dayOfWeekTextColor {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).textColor : nil;
}

- (void)setDateFont:(UIFont *)font {
    for (CKDateButton *dateButton in self.dateButtons) {
        dateButton.titleLabel.font = font;
    }
}
- (UIFont *)dateFont {
    return (self.dateButtons.count > 0) ? ((CKDateButton *)[self.dateButtons lastObject]).titleLabel.font : nil;
}

- (void)setDateBorderColor:(UIColor *)color {
    self.calendarContainer.backgroundColor = color;
}
- (UIColor *)dateBorderColor {
    return self.calendarContainer.backgroundColor;
}

#pragma mark - Calendar helpers

- (NSDate *)firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSDate *)firstDayOfNextMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    comps.month = comps.month + 1;
    return [self.calendar dateFromComponents:comps];
}

- (BOOL)dateIsInCurrentMonth:(NSDate *)date {
    return ([self compareByMonth:date toDate:self.monthShowing] != NSOrderedSame);
}

- (NSComparisonResult)compareByMonth:(NSDate *)date toDate:(NSDate *)otherDate {
    NSDateComponents *day = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDateComponents *day2 = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:otherDate];
    
    if (day.year < day2.year) {
        return NSOrderedAscending;
    } else if (day.year > day2.year) {
        return NSOrderedDescending;
    } else if (day.month < day2.month) {
        return NSOrderedAscending;
    } else if (day.month > day2.month) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSInteger)placeInWeekForDate:(NSDate *)date {
    NSDateComponents *compsFirstDayInMonth = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    return (compsFirstDayInMonth.weekday - 1 - self.calendar.firstWeekday + 8) % 7;
}

- (BOOL)dateIsToday:(NSDate *)date {
    return [self date:[NSDate date] isSameDayAsDate:date];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSDateComponents *day = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

- (NSInteger)numberOfWeeksInMonthContainingDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSDate *)nextDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSDate *)previousDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSInteger)numberOfDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSInteger startDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:endDate];
    return endDay - startDay;
}

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    UIImage *img = [UIImage imageNamed:name];
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;
}

@end