//=========================================================== 
// - initWithFrame
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
	
	// Layout
	KTLayoutManager * aLayoutManger = [[[KTLayoutManager alloc] initWithView:self] autorelease];
	[self setViewLayoutManager:aLayoutManger];
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	[theCoder encodeObject:[self viewLayoutManager] forKey:@"layoutManager"];
}

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if (![super initWithCoder:theCoder])
		return nil;
		
	KTLayoutManager * aLayoutManager = [theCoder decodeObjectForKey:@"layoutManager"];
	if(aLayoutManager == nil)
		aLayoutManager = [[[KTLayoutManager alloc] initWithView:self] autorelease];
	else
		[aLayoutManager setView:self];
	[self setViewLayoutManager:aLayoutManager];

	return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{	
	[mLayoutManager release];
	[super dealloc];
}

//=========================================================== 
// - setViewLayoutManager
//=========================================================== 
- (void)setViewLayoutManager:(KTLayoutManager*)theLayoutManager
{
	if(mLayoutManager != theLayoutManager)
	{
		[mLayoutManager release];
		mLayoutManager = [theLayoutManager retain];
		[self setAutoresizingMask:NSViewNotSizable];
	}
}

//=========================================================== 
// - viewLayoutManager
//=========================================================== 
- (KTLayoutManager*)viewLayoutManager
{
	return mLayoutManager;
}

//=========================================================== 
// - setFrame
//=========================================================== 
- (void)setFrame:(NSRect)theFrame
{
	[super setFrame:theFrame];
}

//=========================================================== 
// - frame
//=========================================================== 
- (NSRect)frame
{
	return [super frame];
}

//=========================================================== 
// - parent
//=========================================================== 
- (id<KTViewLayout>)parent
{
	if([[self superview] conformsToProtocol:@protocol(KTViewLayout)])
		return (id<KTViewLayout>)[self superview];
	else
		return nil;
}

//=========================================================== 
// - children
//=========================================================== 
- (NSArray*)children
{
	return nil;
}
