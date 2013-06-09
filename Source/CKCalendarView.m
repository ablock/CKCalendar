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

#define BUTTON_MARGIN 0
#define CALENDAR_MARGIN 0
#define TOP_HEIGHT 29
#define DAYS_HEADER_HEIGHT 19
#define DEFAULT_CELL_WIDTH 43
#define DEFAULT_CELL_HEIGHT 33
#define CELL_BORDER_WIDTH 0

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
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.buttonStyle) {
        case CKDateButtonStyleToday: [self drawTodayStyleBordersInContext:context]; break;
        case CKDateButtonStyleSelected: [self drawSelectedStyleBordersInContext:context]; break;
        default: [self drawDefaultBordersInContext:context];
    }
}

- (void)drawDefaultBordersInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.952941 green:0.956863 blue:0.960784 alpha:1].CGColor);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.729412 green:0.745098 blue:0.745098 alpha:1].CGColor);
    
    if (self.buttonPosition != CKDateButtonPositionRight) {
        CGContextMoveToPoint(context, self.frame.size.width, 1);
        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    } else {
        CGContextMoveToPoint(context, self.frame.size.width, self.frame.size.height);
    }
    CGContextAddLineToPoint(context, 0, self.frame.size.height);
    CGContextStrokePath(context);
    
    if (self.buttonPosition != CKDateButtonPositionLeft) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.952941 green:0.956863 blue:0.960784 alpha:1].CGColor);
        CGContextMoveToPoint(context, 0, self.frame.size.height - 1);
        CGContextAddLineToPoint(context, 0, 0);
        CGContextStrokePath(context);
    }
}

- (void)drawTodayStyleBordersInContext:(CGContextRef)context
{
    CGColorRef color = [UIColor colorWithRed:0.494118 green:0.494118 blue:0.494118 alpha:1].CGColor;
    [self drawFrameWithLineWidth:2.0 color:color context:context];
    
    CGContextSetLineWidth(context, 0.5);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.588235 green:0.592157 blue:0.592157 alpha:1].CGColor);
    CGContextMoveToPoint(context, 1, 1);
    CGContextAddLineToPoint(context, self.frame.size.width - 1, 1);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.725490 green:0.733333 blue:0.733333 alpha:1].CGColor);
    CGContextMoveToPoint(context, 1, 1.5);
    CGContextAddLineToPoint(context, self.frame.size.width - 1, 1.5);
    CGContextStrokePath(context);
}

- (void)drawSelectedStyleBordersInContext:(CGContextRef)context
{
    CGColorRef color = [UIColor colorWithRed:0.011765 green:0.423529 blue:0.631373 alpha:1].CGColor;
    [self drawFrameWithLineWidth:5.0 color:color context:context];
}

- (void)drawFrameWithLineWidth:(CGFloat)lineWidth color:(CGColorRef)color context:(CGContextRef)context
{
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    CGContextAddLineToPoint(context, 0, self.frame.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
}

@end


@interface CKCalendarView ()

@property(nonatomic, strong) UIButton *titleLabelButton;
@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;
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
    // SET UP THE HEADER
    UIButton *titleLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleLabelButton.backgroundColor = [UIColor clearColor];
    titleLabelButton.showsTouchWhenHighlighted = YES;
    titleLabelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabelButton.titleLabel.backgroundColor = [UIColor clearColor];
    titleLabelButton.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [titleLabelButton addTarget:self action:@selector(selectToday) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:titleLabelButton];
    self.titleLabelButton = titleLabelButton;
    
    UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"left_arrow.png"] forState:UIControlStateNormal];
    prevButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [prevButton addTarget:self action:@selector(moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevButton];
    self.prevButton = prevButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"right_arrow.png"] forState:UIControlStateNormal];
    nextButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
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
    newFrame.size.height = containerHeight + CALENDAR_MARGIN + TOP_HEIGHT;
    self.frame = newFrame;
    
    [self.titleLabelButton setTitle:[self.dateFormatter stringFromDate:_monthShowing] forState:UIControlStateNormal];
    self.titleLabelButton.frame = CGRectMake(0, 0, self.bounds.size.width, TOP_HEIGHT);
    
    self.prevButton.frame = CGRectMake(BUTTON_MARGIN, BUTTON_MARGIN, 48, 38);
    self.nextButton.frame = CGRectMake(self.bounds.size.width - 48 - BUTTON_MARGIN, BUTTON_MARGIN, 48, 38);
    
    self.calendarContainer.frame = CGRectMake(CALENDAR_MARGIN, CGRectGetMaxY(self.titleLabelButton.frame), containerWidth, containerHeight);
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
        dateButton.date = nil;
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
    
    [self.delegate calendar:self didSelectDate:date];
}

- (void)selectToday
{
    [self selectDate:[NSDate date] makeVisible:YES];
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
    [self.delegate calendar:self didSelectDate:date];
    [self setNeedsLayout];
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