#!/usr/bin/env python3
"""Generates the copy-paste code snippets shown in the example app.

One spec per component produces:
  * example/lib/snippets.dart        - the snippet source text, shown in the app
  * example/test/snippets_test.dart  - the same snippets as real code, so
                                       `flutter analyze` / `flutter test`
                                       prove every snippet compiles and builds

Run from the package root:  python3 tool/generate_snippets.py
"""
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# id -> (config arguments, events, commands)
# config: Dart source of the NativeComponentConfig arguments ('' = defaults).
# events: event names the component sends (documented in a comment).
# commands: what controller.trigger() / reset() do, or None.
SPECS = {
    # Navigation & toolbars
    'nav-bar': ("""
      title: 'Inbox',
      items: [
        NativeItem.symbol('Welcome', 'envelope', id: 'welcome'),
        NativeItem.symbol('Receipts', 'doc.text', id: 'receipts'),
      ],
      extra: {'leading': 'Edit', 'trailing': 'square.and.pencil'},
""", 'tap(String), select(itemId)', None),
    'back-button': ("""
      title: 'Library',
      subtitle: 'Details',
      message: 'Use the back button or swipe from the edge.',
""", 'push(String), back(String)', 'trigger() pushes a page'),
    'close-button': ("""
      title: 'Modal',
      message: 'Close me with the glass button.',
      image: NativeImage.symbol('xmark'),
""", 'close(String source)', 'trigger() opens the modal'),
    'nav-title': ("""
      title: 'Favorites',
      subtitle: 'Tap for title menu',
      extra: {'menu': ['Favorites', 'Recents', 'Shared']},
""", 'titleMenu(String)', None),
    'large-nav-title': ("""
      title: 'Large Title',
      image: NativeImage.symbol('plus'),
""", 'tap("add"), select(itemId)', None),
    'toolbar': ("""
      title: 'Toolbar',
      items: [
        NativeItem.symbol('Share', 'square.and.arrow.up', id: 'share'),
        NativeItem.symbol('Favorite', 'heart', id: 'favorite'),
      ],
""", 'tap(itemId), menu(String)', None),
    'floating-toolbar': ("""
      items: [
        NativeItem.symbol('Bold', 'bold', id: 'bold', selected: true),
        NativeItem.symbol('Italic', 'italic', id: 'italic'),
        NativeItem.symbol('Underline', 'underline', id: 'underline'),
        NativeItem.symbol('List', 'list.bullet', id: 'list'),
      ],
      extra: {'split': 3},
""", 'toggle({tool, on})', None),
    'bottom-toolbar': ("""
      title: 'Notes',
      subtitle: '30 Notes',
      items: [
        NativeItem.symbol('Folders', 'folder', id: 'folders'),
        NativeItem.symbol('Compose', 'square.and.pencil', id: 'compose'),
      ],
""", 'tap(itemId)', None),
    'toolbar-action-button': ("""
      title: 'New Event',
      placeholder: 'Title',
      value: 'Weekend trip',
      image: NativeImage.symbol('checkmark'),
""", 'cancel, save(String)', None),

    # Buttons
    'glass-button': ("""
      title: 'Glass',
      image: NativeImage.symbol('sparkles'),
""", 'tap(String)', None),
    'prominent-glass-button': ("""
      title: 'Continue',
      image: NativeImage.symbol('arrow.right'),
      extra: {
        'tints': [Color(0xFF0A84FF), Color(0xFF30D158)],
      },
""", 'tap(String)', None),
    'image-button': ("""
      image: NativeImage.symbol('play.fill'),
      items: [
        NativeItem(id: 'cover1', title: 'Mountains', image: NativeImage.asset('assets/cover1.jpg')),
        NativeItem(id: 'cover2', title: 'Ocean', image: NativeImage.asset('assets/cover2.jpg')),
      ],
      style: NativeStyle(cornerRadius: 24),
""", 'tap(itemId)', None),
    'circular-icon-button': ("""
      items: [
        NativeItem.symbol('Call', 'phone.fill', id: 'call'),
        NativeItem.symbol('Video', 'video.fill', id: 'video'),
        NativeItem.symbol('Message', 'message.fill', id: 'message'),
      ],
""", 'tap(itemId)', None),
    'sf-symbols-button': ("""
      image: NativeImage.symbol('bell.badge.fill'),
""", 'bounce, liked(bool), variableValue(double), tap(String)', None),
    'plus-button': ("""
      value: 5,
      min: 0,
      max: 10,
      step: 1,
""", 'increment(int), decrement(int)', 'trigger() adds one step, reset() restores value'),
    'minus-button': ("""
      value: 5,
      min: 0,
      max: 10,
      step: 1,
""", 'increment(int), decrement(int)', 'trigger() removes one step, reset() restores value'),
    'floating-action-button': ("""
      image: NativeImage.symbol('plus'),
      items: [
        NativeItem.symbol('Photo', 'photo', id: 'photo'),
        NativeItem.symbol('Document', 'doc', id: 'document'),
      ],
""", 'fab(String), action(itemId)', 'trigger() opens / closes the FAB'),
    'avatar-action-button': ("""
      title: 'RP',
      items: [
        NativeItem.symbol('Profile', 'person.crop.circle', id: 'profile'),
        NativeItem.symbol('Settings', 'gear', id: 'settings'),
        NativeItem(id: 'logout', title: 'Sign Out', symbol: 'rectangle.portrait.and.arrow.right', role: NativeItemRole.destructive),
      ],
""", 'menu(itemId)', None),

    # Controls
    'segmented-control': ("""
      items: [
        NativeItem(id: 'day', title: 'Day'),
        NativeItem(id: 'week', title: 'Week'),
        NativeItem(id: 'month', title: 'Month'),
      ],
      value: 'week',
""", 'change(itemId)', None),
    'toggle': ("""
      items: [
        NativeItem.symbol('Airplane Mode', 'airplane', id: 'airplane'),
        NativeItem.symbol('Wi-Fi', 'wifi', id: 'wifi', selected: true),
      ],
      style: NativeStyle(tintColor: Color(0xFF30D158)),
""", 'change({id, on})', 'trigger() toggles the first switch'),
    'stepper': ("""
      title: 'Quantity',
      value: 2,
      min: 0,
      max: 10,
      step: 1,
""", 'change(double)', None),
    'slider': ("""
      title: 'Brightness',
      value: 0.6,
      min: 0,
      max: 1,
      extra: {'minImage': 'sun.min', 'maxImage': 'sun.max'},
""", 'change(double)', 'trigger() sets a random value'),
    'slider-ticks': ("""
      title: 'Playback speed',
      value: 1,
      min: 0.5,
      max: 2,
      step: 0.25,
      extra: {'labels': ['0.5x', '1x', '1.5x', '2x']},
""", 'change(double)', None),
    'page-indicator': ("""
      items: [
        NativeItem(id: 'p1', title: 'One', symbol: 'mountain.2.fill'),
        NativeItem(id: 'p2', title: 'Two', symbol: 'sun.max.fill'),
        NativeItem(id: 'p3', title: 'Three', symbol: 'tree.fill'),
      ],
      value: 0,
""", 'change(int)', 'trigger() goes to the next page'),
    'checkbox': ("""
      title: 'Reminders',
      items: [
        NativeItem(id: 'milk', title: 'Buy milk', selected: true),
        NativeItem(id: 'ship', title: 'Ship the app'),
      ],
""", 'change({id, checked})', None),

    # Structure
    'tab-bar': ("""
      items: [
        NativeItem.symbol('Home', 'house.fill', id: 'home'),
        NativeItem.symbol('Browse', 'square.grid.2x2.fill', id: 'browse'),
        NativeItem.symbol('Library', 'books.vertical.fill', id: 'library'),
      ],
      value: 'home',
""", 'change(itemId)', 'trigger() selects the next tab'),
    'floating-tab-bar': ("""
      items: [
        NativeItem.symbol('Home', 'house.fill', id: 'home'),
        NativeItem.symbol('Radio', 'dot.radiowaves.left.and.right', id: 'radio'),
        NativeItem.symbol('Library', 'books.vertical.fill', id: 'library'),
      ],
""", 'change(itemId)', None),
    'tab-bar-item': ("""
      message: 'Each tab item has an image, a title and an optional badge.',
      items: [
        NativeItem.symbol('Activity', 'bell.fill', id: 'activity'),
        NativeItem.symbol('Messages', 'message.fill', id: 'messages', badge: 'New'),
        NativeItem.symbol('Profile', 'person.fill', id: 'profile'),
      ],
""", 'change(itemId), badge(int)', None),
    'expandable-tab-bar': ("""
      items: [
        NativeItem.symbol('Home', 'house.fill', id: 'home'),
        NativeItem.symbol('Browse', 'square.grid.2x2.fill', id: 'browse'),
        NativeItem.symbol('Library', 'books.vertical.fill', id: 'library'),
      ],
      value: 'home',
""", 'change(itemId)', None),
    'search-tab': ("""
      placeholder: 'Artists, songs and more',
      items: [
        NativeItem.symbol('Home', 'house.fill', id: 'home'),
        NativeItem.symbol('Library', 'books.vertical.fill', id: 'library'),
      ],
      extra: {'results': ['Ahmedabad', 'London', 'Tokyo']},
""", 'change(itemId), search(String)', None),
    'sidebar': ("""
      title: 'Mailboxes',
      message: 'Selected from the sidebar.',
      items: [
        NativeItem.symbol('Inbox', 'tray', id: 'inbox', badge: '3'),
        NativeItem.symbol('Sent', 'paperplane', id: 'sent'),
        NativeItem.symbol('Trash', 'trash', id: 'trash'),
      ],
""", 'change(itemId)', None),
    'navigation-stack': ("""
      title: 'Root',
      extra: {'pushLabel': 'Push level', 'popLabel': 'Pop to root'},
""", 'change(String path)', 'trigger() pushes a level, reset() pops to root'),
    'split-view': ("""
      items: [
        NativeItem(id: 'fruits', title: 'Fruits', children: [
          NativeItem(id: 'apple', title: 'Apple'),
          NativeItem(id: 'mango', title: 'Mango'),
        ]),
        NativeItem(id: 'veggies', title: 'Vegetables', children: [
          NativeItem(id: 'carrot', title: 'Carrot'),
        ]),
      ],
""", 'category(itemId), item(itemId)', None),
    'floating-accessory': ("""
      title: 'Liquid Dreams',
      subtitle: 'Glass Ensemble',
      image: NativeImage.symbol('music.note'),
""", 'playback(String)', None),
    'inspector': ("""
      title: 'Canvas',
      style: NativeStyle(cornerRadius: 24, tintColor: Color(0xFFBF5AF2)),
""", 'inspector(String), change({color, opacity, corner})', 'trigger() shows / hides the inspector'),

    # Presentation
    'bottom-sheet': ("""
      title: 'Places',
      placeholder: 'Search Maps',
      extra: {'detents': ['120pt', 'medium', 'large']},
""", 'presented, dismissed, detent(String), select(itemId)', 'trigger() shows / hides the sheet'),
    'half-sheet': ("""
      title: 'Options',
      items: [
        NativeItem.symbol('Share', 'square.and.arrow.up', id: 'share'),
        NativeItem.symbol('Duplicate', 'plus.square.on.square', id: 'duplicate'),
      ],
""", 'presented, dismissed, select(itemId)', 'trigger() presents the sheet'),
    'full-sheet': ("""
      title: 'Welcome',
      message: 'A full-screen cover with a close button.',
""", 'presented, dismissed', 'trigger() presents the cover'),
    'detented-sheet': ("""
      extra: {'detents': ['0.25', 'medium', 'large']},
""", 'detent(String)', 'trigger() presents the sheet'),
    'drag-indicator': ("""
      title: 'Sheet',
      message: 'Drag me up and down.',
      value: true,
""", 'indicator(bool), presented, dismissed', 'trigger() presents the sheet'),
    'alert': ("""
      title: 'Delete photo?',
      message: 'This action cannot be undone.',
      placeholder: 'New name',
      items: [
        NativeItem(id: 'cancel', title: 'Cancel', role: NativeItemRole.cancel),
        NativeItem(id: 'delete', title: 'Delete', role: NativeItemRole.destructive),
      ],
""", 'action(itemId), rename(String)', 'trigger() shows the alert'),
    'confirmation-dialog': ("""
      title: 'Discard changes?',
      message: 'Your edits will be lost.',
      items: [
        NativeItem(id: 'discard', title: 'Discard', role: NativeItemRole.destructive),
        NativeItem(id: 'keep', title: 'Keep Editing', role: NativeItemRole.cancel),
      ],
""", 'action(itemId)', 'trigger() shows the dialog'),
    'action-sheet': ("""
      title: 'Photo',
      message: 'Choose an action',
      items: [
        NativeItem(id: 'save', title: 'Save to Files'),
        NativeItem(id: 'delete', title: 'Delete', role: NativeItemRole.destructive),
        NativeItem(id: 'cancel', title: 'Cancel', role: NativeItemRole.cancel),
      ],
""", 'action(itemId)', 'trigger() shows the action sheet'),
    'popover': ("""
      title: 'Text options',
      image: NativeImage.symbol('textformat.size'),
      items: [
        NativeItem(id: 'small', title: 'Small'),
        NativeItem(id: 'large', title: 'Large'),
      ],
""", 'select(itemId)', 'trigger() shows the popover'),
    'toast': ("""
      title: 'Saved to Photos',
      image: NativeImage.symbol('checkmark.circle.fill'),
      extra: {'duration': 2.5, 'position': 'top'},
""", 'shown(String), dismissed', "trigger() shows the toast; send('trigger', 'Custom message') overrides the text"),
    'confirmation-popup': ("""
      title: 'Order placed',
      message: 'Your order will arrive tomorrow.',
      image: NativeImage.symbol('checkmark.seal.fill'),
      items: [
        NativeItem(id: 'cancel', title: 'Close'),
        NativeItem(id: 'track', title: 'Track order'),
      ],
""", 'result(itemId | "dismiss")', 'trigger() shows the popup'),

    # Menus
    'popup-menu': ("""
      title: 'Repeat',
      items: [
        NativeItem(id: 'never', title: 'Never'),
        NativeItem(id: 'daily', title: 'Every Day'),
        NativeItem(id: 'weekly', title: 'Every Week'),
      ],
      value: 'never',
""", 'change(itemId)', None),
    'dropdown-menu': ("""
      title: 'Sort',
      image: NativeImage.symbol('line.3.horizontal.decrease'),
      items: [
        NativeItem(id: 'date', title: 'Date'),
        NativeItem(id: 'name', title: 'Name'),
      ],
      value: 'date',
""", 'change(itemId), ascending(bool)', None),
    'context-menu': ("""
      title: 'Long-press a photo',
      extra: {'actions': ['Copy', 'Favorite', 'Delete']},
""", 'action({item, action})', None),
    'overflow-menu': ("""
      title: 'Projects',
      image: NativeImage.symbol('ellipsis'),
      items: [
        NativeItem.symbol('Select', 'checkmark.circle', id: 'select'),
        NativeItem.symbol('Sort', 'arrow.up.arrow.down', id: 'sort'),
      ],
""", 'select(itemId)', None),
    'nested-submenu': ("""
      title: 'File',
      image: NativeImage.symbol('doc'),
      items: [
        NativeItem(id: 'new', title: 'New'),
        NativeItem(title: 'Export', children: [
          NativeItem(id: 'pdf', title: 'PDF'),
          NativeItem(id: 'png', title: 'PNG'),
        ]),
      ],
""", 'select(itemId)', None),
    'share-menu': ("""
      title: 'Check out glassy_ui_ios',
      message: 'Native iOS components',
      extra: {'url': 'https://pub.dev/packages/glassy_ui_ios'},
""", 'shareLink, completed({activity, completed})', 'trigger() opens the share sheet'),
    'text-selection-menu': ("""
      message: 'Select any words in this paragraph to see the custom actions.',
      items: [
        NativeItem(id: 'send', title: 'Send to Flutter'),
        NativeItem(id: 'highlight', title: 'Highlight'),
      ],
""", '<itemId>(String selectedText)', None),

    # Input & pickers
    'text-field': ("""
      placeholder: 'Full name',
      extra: {'keyboard': 'default'},
""", 'submit(String), send(String)', None),
    'secure-field': ("""
      placeholder: 'Password',
""", 'submit({length, strength}), strength(String)', None),
    'search-field': ("""
      title: 'Cities',
      placeholder: 'Search',
      items: [
        NativeItem(id: 'ahmedabad', title: 'Ahmedabad'),
        NativeItem(id: 'london', title: 'London'),
        NativeItem(id: 'tokyo', title: 'Tokyo'),
      ],
      extra: {'suggestions': ['London', 'Tokyo']},
""", 'search(String), select(itemId)', None),
    'text-editor': ("""
      title: 'Notes',
      value: 'Write something long here...',
      max: 500,
""", 'done({characters, text})', None),
    'date-picker': ("""
      title: 'Date',
      value: DateTime(2026, 10, 25),
      extra: {'style': 'graphical'},
""", 'change(ISO-8601 String)', None),
    'time-picker': ("""
      title: 'Time',
      value: DateTime(2026, 10, 25, 9, 41),
""", 'change({hour, minute, iso})', None),
    'wheel-picker': ("""
      items: [
        NativeItem(title: 'Hours', children: [
          NativeItem(id: '0', title: '0 h'),
          NativeItem(id: '1', title: '1 h'),
          NativeItem(id: '2', title: '2 h'),
        ]),
        NativeItem(title: 'Minutes', children: [
          NativeItem(id: '0', title: '0 min'),
          NativeItem(id: '30', title: '30 min'),
        ]),
      ],
      value: ['1', '30'],
""", 'change(List<String>)', None),
    'menu-picker': ("""
      title: 'Language',
      items: [
        NativeItem(id: 'swift', title: 'Swift'),
        NativeItem(id: 'dart', title: 'Dart'),
      ],
      value: 'dart',
""", 'change(itemId)', None),
    'color-picker': ("""
      title: 'Accent colour',
      value: Color(0xFF0091FF),
      extra: {'supportsOpacity': false},
""", 'change({hex, argb})', None),
    'floating-search-bar': ("""
      title: 'Explore',
      placeholder: 'Search',
      image: NativeImage.symbol('mic.fill'),
""", 'search(String), tap("accessory")', 'trigger() focuses the search field'),

    # Progress
    'circular-progress': ("""
      title: 'Storage',
      value: 0.49,
      extra: {'lineWidth': 12},
      style: NativeStyle(tintColor: Color(0xFF30D158)),
""", 'complete', None),
    'linear-progress': ("""
      title: 'Syncing photos',
      value: 0.4,
""", 'complete', None),
    'determinate-progress': ("""
      title: 'Setup',
      value: 2,
      max: 5,
""", 'change(int)', 'trigger() next step, reset() back to zero'),
    'indeterminate-loading': ("""
      title: 'Loading…',
""", '-', None),
    'download-progress': ("""
      title: 'Glass Studio',
      subtitle: '128 MB',
      image: NativeImage.symbol('app.gift.fill'),
      extra: {'openTitle': 'OPEN'},
""", 'start(int), pause(int), progress(int), complete, open', 'trigger() starts / pauses, reset() restarts'),
    'upload-progress': ("""
      title: 'Uploading',
      items: [
        NativeItem(id: 'img', title: 'IMG_2041.HEIC'),
        NativeItem(id: 'mov', title: 'Trip.mov'),
      ],
""", 'uploaded(itemId), complete', 'trigger() / reset() restart the uploads'),
    'activity-indicator': ("""
      title: 'UIActivityIndicatorView',
      value: true,
      style: NativeStyle(tintColor: Color(0xFFFF375F)),
""", 'change(bool)', 'trigger() starts / stops animating'),

    # Media & camera
    'gallery-toolbar': ("""
      title: 'Library',
      extra: {'count': 45},
""", 'open(itemId), selecting(bool), share(List), delete(List)', None),
    'photo-viewer-toolbar': ("""
      title: 'Today',
      subtitle: '9:41 AM',
      image: NativeImage.asset('assets/photo.jpg'),
""", 'tap(String), favorite(bool)', None),
    'media-controls': ("""
      title: 'Liquid Dreams',
      subtitle: 'Glass Ensemble',
      image: NativeImage.asset('assets/album.jpg'),
      value: 0.3,
      max: 215,
""", 'play, pause, previous, next, seek(int), volume(double)', 'trigger() plays / pauses'),
    'play-pause': ("""
      value: false,
      extra: {'size': 110},
""", 'play, pause', 'trigger() plays / pauses'),
    'skip-buttons': ("""
      value: 60,
      extra: {'back': 15, 'forward': 30},
""", 'skipBackward(int), skipForward(int)', None),
    'volume-slider': ("""
      title: 'App volume',
      value: 0.5,
      extra: {'showSystem': true},
""", 'change(double)', None),
    'media-close': ("""
      image: NativeImage.asset('assets/video_poster.jpg'),
      extra: {'showMinimize': true},
""", 'close("xmark" | "minimize")', None),
    'pip-controls': ("""
      title: 'Now watching',
      image: NativeImage.asset('assets/video_poster.jpg'),
""", 'pip({active, systemSupported}), snap(String), close', 'trigger() turns picture-in-picture on / off'),
    'camera-controls': ("""
      image: NativeImage.asset('assets/viewfinder.jpg'),
      value: 'photo',
""", 'flash(bool), mode(itemId), capture({mode, count}), flip, tap("live")', None),
    'zoom-controls': ("""
      image: NativeImage.asset('assets/viewfinder.jpg'),
      value: 1,
      max: 10,
      extra: {'presets': [0.5, 1, 2, 5]},
""", 'change(double)', None),
    'crop-controls': ("""
      image: NativeImage.asset('assets/photo.jpg'),
      items: [
        NativeItem(id: 'free', title: 'Free'),
        NativeItem(id: '1:1', title: 'Square'),
        NativeItem(id: '16:9', title: '16:9'),
      ],
""", 'aspect(itemId), rotate(int), flip(bool), done({angle, aspect})', None),

    # Liquid Glass
    'scroll-edge': ("""
      title: 'Gallery',
      value: 'soft',
""", 'change(String)', None),
    'glass-background': ("""
      items: [
        NativeItem(id: 'regular', title: 'Regular', subtitle: 'Adapts to content'),
        NativeItem(id: 'clear', title: 'Clear', subtitle: 'For media-rich backgrounds'),
      ],
      style: NativeStyle(glassTint: Color(0x660A84FF)),
""", '-', None),
    'custom-glass-shape': ("""
      items: [
        NativeItem(id: 'circle', title: 'Circle', symbol: 'sparkles'),
        NativeItem(id: 'capsule', title: 'Capsule', symbol: 'sparkles'),
        NativeItem(id: 'star', title: 'Star', symbol: 'sparkles'),
      ],
      extra: {'size': 130},
""", 'tap(itemId)', None),
    'glass-button-group': ("""
      items: [
        NativeItem.symbol('Left', 'text.alignleft', id: 'left'),
        NativeItem.symbol('Center', 'text.aligncenter', id: 'center'),
        NativeItem.symbol('Right', 'text.alignright', id: 'right'),
      ],
      value: 'left',
""", 'change(itemId), tap(String)', None),
    'glass-container': ("""
      items: [
        NativeItem.symbol('Sun', 'sun.max.fill', id: 'sun'),
        NativeItem.symbol('Moon', 'moon.fill', id: 'moon'),
        NativeItem.symbol('Cloud', 'cloud.fill', id: 'cloud'),
      ],
      value: 40,
      min: 0,
      max: 80,
""", 'change(int spacing)', None),
    'glass-morphing': ("""
      image: NativeImage.symbol('paintbrush.pointed.fill'),
      items: [
        NativeItem.symbol('Pen', 'pencil.tip', id: 'pen'),
        NativeItem.symbol('Eraser', 'eraser', id: 'eraser'),
      ],
      value: false,
""", 'expanded, collapsed, select(itemId)', 'trigger() expands / collapses'),
    'glass-transition': ("""
      items: [
        NativeItem.symbol('Alerts', 'bell.fill', id: 'bell'),
        NativeItem.symbol('Likes', 'heart.fill', id: 'heart'),
      ],
      value: 'materialize',
""", 'shown(String), hidden(String)', 'trigger() shows / hides the glass'),
    'app-icon': ("""
      image: NativeImage.symbol('drop.fill'),
      value: 'Default',
      style: NativeStyle(
        backgroundGradient: [Color(0xFF64D2FF), Color(0xFF0A84FF)],
        glassTint: Color(0xFF0A84FF),
      ),
""", 'change(String)', None),
    'widget-appearance': ("""
      title: 'Up Next',
      subtitle: 'Design review',
      message: '10:30 – 11:15 AM',
      value: 'Full Color',
      extra: {'city': 'Cupertino', 'temperature': 21, 'battery': 0.72},
""", 'change(String)', None),
}


def camel(component_id: str) -> str:
    head, *rest = component_id.split('-')
    return head + ''.join(part.capitalize() for part in rest)


def snippet(component_id: str, title: str, api: str) -> str:
    config, events, commands = SPECS[component_id]
    lines = [f'// {title} — {api}']
    if events != '-':
        lines.append(f'// Events: {events}')
    if commands:
        lines.append(f'// Controller: {commands}')
        lines.append('// (declare `NativeComponentController? controller;` in your State)')
    lines.append('SizedBox(')
    lines.append('  height: 420,')
    lines.append('  child: NativeComponent(')
    lines.append(f'    type: NativeComponentType.{camel(component_id)},')
    body = config.strip('\n')
    if body:
        const = '' if 'DateTime(' in body else 'const '
        lines.append(f'    config: {const}NativeComponentConfig(')
        lines.extend(body.split('\n'))
        lines.append('    ),')
    if events != '-':
        lines.append("    onEvent: (event) => debugPrint('${event.name}: ${event.value}'),")
    if commands:
        lines.append('    onCreated: (c) => controller = c,')
    lines.append('  ),')
    lines.append(')')
    return '\n'.join(lines)


def main() -> None:
    source = (ROOT / 'lib/src/component_type.dart').read_text()
    types = re.findall(r"^  (\w+)\(\s*'([a-z-]+)',\s*'([^']+)',\s*NativeComponentCategory\.\w+,\s*'([^']*)'", source, re.M)
    assert len(types) == 90, f'expected 90 component types, found {len(types)}'
    missing = {t[1] for t in types} - SPECS.keys()
    extra = SPECS.keys() - {t[1] for t in types}
    assert not missing and not extra, f'missing: {missing}, unknown: {extra}'
    for name, component_id, _, _ in types:
        assert name == camel(component_id), f'{component_id}: enum is {name}'

    snippets = {cid: snippet(cid, title, api) for _, cid, title, api in types}

    header = '// GENERATED by tool/generate_snippets.py. Do not edit by hand.\n'
    entries = '\n'.join(f"  '{cid}': r'''\n{code}\n''',\n" for cid, code in snippets.items())
    (ROOT / 'example/lib/snippets.dart').write_text(
        header
        + '\n/// Copy-paste ready code for every component, keyed by component id.\n'
        + 'const Map<String, String> componentSnippets = {\n'
        + entries
        + '};\n'
    )

    builders = '\n'.join(
        f"    '{cid}': () => {code[code.index('SizedBox('):]},"
        for cid, code in snippets.items()
    )
    (ROOT / 'example/test').mkdir(exist_ok=True)
    (ROOT / 'example/test/snippets_test.dart').write_text(header + f"""
// Every snippet shown in the app is compiled here, so `flutter analyze`
// fails if one of them goes stale.
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glassy_ui_ios/glassy_ui_ios.dart';
import 'package:glassy_ui_ios_example/snippets.dart';

class _Snippets {{
  NativeComponentController? controller;

  late final Map<String, Widget Function()> builders = {{
{builders}
  }};
}}

void main() {{
  final snippets = _Snippets();

  test('every component has a snippet', () {{
    for (final type in NativeComponentType.values) {{
      expect(componentSnippets[type.id], isNotNull, reason: type.id);
      expect(snippets.builders[type.id], isNotNull, reason: type.id);
    }}
  }});

  testWidgets('every snippet builds', (tester) async {{
    for (final entry in snippets.builders.entries) {{
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: entry.value())));
      expect(find.byType(NativeComponent), findsOneWidget, reason: entry.key);
    }}
  }});
}}
""")
    subprocess.run(['dart', 'format', 'example/lib/snippets.dart', 'example/test/snippets_test.dart'], cwd=ROOT, check=True, capture_output=True)
    print(f'snippets written: {len(snippets)}')


if __name__ == '__main__':
    main()
