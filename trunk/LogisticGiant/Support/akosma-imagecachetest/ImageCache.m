//
//  ImageCache.m
//  ImageCacheTest
//
//  Created by Adrian on 1/28/09.
//  Copyright 2009 Adrian Kosmaczewski. All rights reserved.
//

#import "ImageCache.h"
#import "GTMObjectSingleton.h"

@interface ImageCache (Private)

- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key;

@end


@implementation ImageCache

#pragma mark -
#pragma mark Singleton definition

GTMOBJECT_SINGLETON_BOILERPLATE(ImageCache, sharedImageCache)

#pragma mark -
#pragma mark Constructor and destructor

- (id)init
{
    if (self = [super init])
    {
        keyArray = [[NSMutableArray alloc] initWithCapacity:MEMORY_CACHE_SIZE];
        memoryCache = [[NSMutableDictionary alloc] initWithCapacity:MEMORY_CACHE_SIZE];
    }
    return self;
}

- (void)dealloc
{
    [keyArray release];
    keyArray = nil;
    [memoryCache release];
    memoryCache = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *image = [memoryCache objectForKey:key];
    return image;
}

- (BOOL)hasImageWithKey:(NSString *)key
{
    BOOL exists = [self imageExistsInMemory:key];
    return exists;
}

- (void)storeImage:(UIImage *)image withKey:(NSString *)key
{
    if (image != nil && key != nil)
    {
        [self addImageToMemoryCache:image withKey:key];
    }
}

- (void)removeImageWithKey:(NSString *)key
{
    if ([self imageExistsInMemory:key])
    {
        NSUInteger index = [keyArray indexOfObject:key];
        [keyArray removeObjectAtIndex:index];
        [memoryCache removeObjectForKey:key];
    }
}

- (void)removeAllImages
{
    [self removeAllImagesInMemory];
}

- (void)removeAllImagesInMemory
{
    [memoryCache removeAllObjects];
}

- (BOOL)imageExistsInMemory:(NSString *)key
{
    return ([memoryCache objectForKey:key] != nil);
}

- (NSUInteger)countImagesInMemory
{
    return [memoryCache count];
}

- (NSInteger)estimatedMemoryCacheMemorySize {
  int memSize = 0;
  for (UIImage *name in memoryCache) {
    UIImage *img = [memoryCache objectForKey:name];
    memSize += img.size.width * img.size.height * 4;
  }
  return memSize;
}

#pragma mark -
#pragma mark Private methods

- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key
{
    // Add the object to the memory cache for faster retrieval next time
    [memoryCache setObject:image forKey:key];
    
    // Add the key at the beginning of the keyArray
    [keyArray insertObject:key atIndex:0];

    // Remove the first object added to the memory cache
    if ([keyArray count] > MEMORY_CACHE_SIZE)
    {
        // This is the "raison d'etre" de keyArray:
        // we use it to keep track of the last object
        // in it (that is, the first we've inserted), 
        // so that the total size of objects in memory
        // is never higher than MEMORY_CACHE_SIZE.
        NSString *lastObjectKey = [keyArray lastObject];
        [memoryCache removeObjectForKey:lastObjectKey];
        [keyArray removeLastObject];
    }    
}

@end
