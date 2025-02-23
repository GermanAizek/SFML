////////////////////////////////////////////////////////////
//
// SFML - Simple and Fast Multimedia Library
// Copyright (C) 2007-2021 Marco Antognini (antognini.marco@gmail.com),
//                         Laurent Gomila (laurent@sfml-dev.org)
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it freely,
// subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented;
//    you must not claim that you wrote the original software.
//    If you use this software in a product, an acknowledgment
//    in the product documentation would be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such,
//    and must not be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source distribution.
//
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////
#include <SFML/Window/OSX/CursorImpl.hpp>

#import <SFML/Window/OSX/AutoreleasePoolWrapper.h>
#import <SFML/Window/OSX/NSImage+raw.h>
#import <AppKit/AppKit.h>

namespace
{

////////////////////////////////////////////////////////////
NSCursor* loadFromSelector(SEL selector)
{
    // The caller is responsible for retaining the cursor.
    if ([NSCursor respondsToSelector:selector])
        return [NSCursor performSelector:selector];
    else
        return nil;
}

}

namespace sf
{
namespace priv
{

////////////////////////////////////////////////////////////
CursorImpl::CursorImpl() :
m_cursor(nil)
{
    // Just ask for a pool
    ensureThreadHasPool();
}


////////////////////////////////////////////////////////////
CursorImpl::~CursorImpl()
{
    [m_cursor release];
}


////////////////////////////////////////////////////////////
bool CursorImpl::loadFromPixels(const Uint8* pixels, const Vector2u& size, const Vector2u& hotspot)
{
    if (m_cursor)
    {
        [m_cursor release];
        m_cursor = nil;
    }

    NSSize   nssize    = NSMakeSize(size.x, size.y);
    NSImage* image     = [NSImage imageWithRawData:pixels andSize:nssize];
    NSPoint  nshotspot = NSMakePoint(hotspot.x, hotspot.y);

    m_cursor = [[NSCursor alloc] initWithImage:image hotSpot:nshotspot];

    return m_cursor != nil;
}

////////////////////////////////////////////////////////////
bool CursorImpl::loadFromSystem(Cursor::Type type)
{
    NSCursor* newCursor = nil;

    switch (type)
    {
        default: return false;

        case Cursor::Arrow:           newCursor = [NSCursor arrowCursor];               break;
        case Cursor::Text:            newCursor = [NSCursor IBeamCursor];               break;
        case Cursor::Hand:            newCursor = [NSCursor pointingHandCursor];        break;
        case Cursor::SizeHorizontal:  newCursor = [NSCursor resizeLeftRightCursor];     break;
        case Cursor::SizeVertical:    newCursor = [NSCursor resizeUpDownCursor];        break;
        case Cursor::Cross:           newCursor = [NSCursor crosshairCursor];           break;
        case Cursor::NotAllowed:      newCursor = [NSCursor operationNotAllowedCursor]; break;
        case Cursor::SizeLeft:        newCursor = [NSCursor resizeLeftRightCursor];     break;
        case Cursor::SizeRight:       newCursor = [NSCursor resizeLeftRightCursor];     break;
        case Cursor::SizeTop:         newCursor = [NSCursor resizeUpDownCursor];        break;
        case Cursor::SizeBottom:      newCursor = [NSCursor resizeUpDownCursor];        break;
            
        // These cursor types are undocumented, may not be available on some platforms
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        case Cursor::SizeTopRight:
        case Cursor::SizeBottomLeft:
        case Cursor::SizeBottomLeftTopRight:
            newCursor = loadFromSelector(@selector(_windowResizeNorthEastSouthWestCursor));
            break;

        case Cursor::SizeTopLeft:
        case Cursor::SizeBottomRight:
        case Cursor::SizeTopLeftBottomRight:
            newCursor = loadFromSelector(@selector(_windowResizeNorthWestSouthEastCursor));
            break;

        case Cursor::Help:
            newCursor = loadFromSelector(@selector(_helpCursor));
            break;
#pragma clang diagnostic pop
    }

    if (newCursor)
    {
        [m_cursor release];
        m_cursor = newCursor;
        [m_cursor retain];
    }

    return newCursor != nil;
}


} // namespace priv

} // namespace sf

