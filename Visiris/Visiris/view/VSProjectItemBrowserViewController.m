//
//  VSProjectItemBrowserViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectItemBrowserViewController.h"

#import "VSProjectItemRepresentationController.h"
#import "VSProjectItem.h"
#import "VSProjectItemRepresentation.h"
#import "ImageAndTextCell.h"
#import "VSProjectItem.h"
#import "VSProjectItemController.h"

#import "VSCoreServices.h"

@interface VSProjectItemBrowserViewController ()

@property VSProjectItemRepresentationController *projectItemRepresentationController;

@property VSProjectItemController *projectItemController;

@end

/** identifier of the name column*/
#define COLUMNID_NAME       @"name"

/** identifier of the file size column*/
#define COLUMNID_FILE_SIZE  @"fileSize"

/** identifier of the duration column*/
#define COLUMNID_DURATION   @"duration"

/** identifier of the file path column*/
#define COLUMNID_FILE_PATH  @"filePath"

@implementation VSProjectItemBrowserViewController
@synthesize tvwProjectItmes = _tvwProjectItmes;
@synthesize projectItemRepresentationController = _projectItemRepresentationController;
@synthesize projectItemController = _projectItemController;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSProjectItemBrowserView";

#pragma mark - Init

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.projectItemRepresentationController = [VSProjectItemRepresentationController sharedManager];
        
        [self.projectItemRepresentationController addObserver:self forKeyPath:@"projectItemRepresentations" options:0 context:nil];
        
        self.projectItemController =[VSProjectItemController sharedManager];
    }
    return self;
}

#pragma mark - NSView Implementation

-(void) awakeFromNib{
    [self.tvwProjectItmes setAllowsMultipleSelection:YES];
    [self.tvwProjectItmes registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [self setColumnNames];
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"projectItemRepresentations"]){
        [self.tvwProjectItmes reloadData];
    }
}

#pragma mark- Drag and Drop

-(id<NSPasteboardWriting>) tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row{
    return [self.projectItemRepresentationController.projectItemRepresentations objectAtIndex:row];
}



#pragma mark- NSTableViewDataSource Implementation

-(BOOL) tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation{
    
    //if the draggingPasteboard stored in draggingInfo contains file-paths (NSFilenamesPboardType) the paths are read out. VSProjectItemRepresentation are created for every filePath and added to droppedProjectItems
    if([[[info draggingPasteboard] types ] containsObject:NSFilenamesPboardType]){
        
        //Stores data of NSFilenamesPboardType stored in draggingPasteboard of draggingInfo
        NSData *data = [[info draggingPasteboard] dataForType:NSFilenamesPboardType];
        
        //reads out the file-paths of data
        NSArray *fileNames = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:kCFPropertyListImmutable errorDescription:nil];
        
        //for every filePath a temporary VSProjectItem is created to create a VSProjectItemRepresentation
        for(NSString *fileName in fileNames){
            [self.projectItemController addNewProjectItemFromFile:fileName];
        }
        return YES;
    }
    
    return NO;
    
}

-(NSDragOperation) tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    
    return NSDragOperationCopy;
}


-(id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    //Sets the icon of the row
    if([[tableColumn identifier] isEqualTo:COLUMNID_NAME]){
        if([tableColumn.dataCell isKindOfClass:[ImageAndTextCell class]]){
            ((ImageAndTextCell*) tableColumn.dataCell).image = ((VSProjectItemRepresentation *)[self.projectItemRepresentationController.projectItemRepresentations objectAtIndex:row]).icon;
        }
    }
    return [[self.projectItemRepresentationController.projectItemRepresentations objectAtIndex:row] valueForKey:[tableColumn identifier]];
}


-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.projectItemRepresentationController.projectItemRepresentations count];
}

#pragma mark - NSTableViewDelegate implementation

-(void) tableViewSelectionDidChange:(NSNotification *)notification{
    
    NSIndexSet *selectedRowIndexes = [self.tvwProjectItmes selectedRowIndexes];
    
    if(selectedRowIndexes.count > 0){
        NSArray *selectedProjectItemRepresentations = [self.projectItemRepresentationController.projectItemRepresentations objectsAtIndexes:selectedRowIndexes];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VSProjectItemRepresentationGotSelected object:selectedProjectItemRepresentations];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSProjectItemRepresentationGotUnselected object:nil];
    }
}

#pragma mark - Private Methods

/**
 * Sets names of the tableview's column headerCells
 */
- (void)setColumnNames {
    for(NSTableColumn *column in [self.tvwProjectItmes tableColumns]){
        if([[column identifier] isEqualToString:COLUMNID_FILE_SIZE]){
            [column.headerCell setStringValue:NSLocalizedString(@"File Size", @"Size of the file in Bytes")];
        }
        if([[column identifier] isEqualToString:COLUMNID_DURATION]){
            [column.headerCell setStringValue:NSLocalizedString(@"Duration", @"Duration of a time-based file")];
        }
        if([[column identifier] isEqualToString:COLUMNID_NAME]){
            [column.headerCell setStringValue:NSLocalizedString(@"Name", @"Name of an item")];
        }
        if([[column identifier] isEqualToString:COLUMNID_FILE_PATH]){
            [column.headerCell setStringValue:NSLocalizedString(@"Location", @"Location of a file")];
        }
    }
}

@end
