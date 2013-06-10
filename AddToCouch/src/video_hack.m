//    [self hackVideo:@"ipod-library://item/item.m4v?id=-2284389838251421813"];
/*    AVURLAsset *asset=[[[AVURLAsset alloc] initWithURL:u options:nil] autorelease];
    AVAssetReader *asset_reader=[[[AVAssetReader alloc] initWithAsset:asset error:nil] autorelease];
    NSArray* video_tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    NSLog(@"video tracks: %@", video_tracks);
    AVAssetTrack* video_track = [video_tracks objectAtIndex:0];
    NSLog(@"vid: %@", video_track);
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];

    [dictionary setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]  forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
     
    // AVAssetReaderTrackOutput* asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:video_track outputSettings:dictionary];
//    [asset_reader addOutput:asset_reader_output];
     [asset_reader startReading];
        NSMutableData *fullSongData = [[NSMutableData alloc] init];

     while ( [asset_reader status]==AVAssetReaderStatusReading ){
         AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[asset_reader.outputs objectAtIndex:0];
         CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
         
         if (sampleBufferRef){
             CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
             size_t length = CMBlockBufferGetDataLength(blockBufferRef);
             NSLog(@"read buffer %lu", CMBlockBufferGetDataLength(blockBufferRef));
             NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
             CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
             [fullSongData appendData:data];
             [data release];
             
             CMSampleBufferInvalidate(sampleBufferRef);
             CFRelease(sampleBufferRef);
         }
            //buffer = [asset_reader_output copyNextSampleBuffer];

     }
    NSLog(@"read: %d", [fullSongData length]);
   // [asset_reader_output release];
    NSLog(@"setatus %d", [asset_reader status]);*/

//    NSURL *u = [NSURL URLWithString:@"ipod-library://item/item.m4v?id=-2284389838251421813"];
//    NSData *myData = [NSData dataWithContentsOfURL:u];
//    NSLog(@"my data? %@", myData);
