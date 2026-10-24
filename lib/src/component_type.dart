/// Grouping used for catalogs and documentation.
enum NativeComponentCategory {
  /// Navigation bars, titles and toolbars.
  navigation('Navigation & Toolbars'),

  /// Glass, prominent, icon and action buttons.
  buttons('Buttons'),

  /// Segmented controls, toggles, steppers, sliders and checkboxes.
  controls('Controls'),

  /// Tab bars, sidebars, navigation stacks and split views.
  structure('Tabs & Structure'),

  /// Sheets, alerts, dialogs, popovers and toasts.
  presentation('Sheets, Dialogs & Overlays'),

  /// Pop-up, dropdown, context, overflow and share menus.
  menus('Menus'),

  /// Text fields, search, editors and pickers.
  input('Input & Pickers'),

  /// Progress bars, rings and activity indicators.
  progress('Progress'),

  /// Playback, photo, camera and crop controls.
  media('Media & Camera'),

  /// Liquid Glass effects, shapes and transitions.
  glass('Liquid Glass');

  const NativeComponentCategory(this.title);

  /// Human-readable category name.
  final String title;
}

/// Every built-in native component.
///
/// The Swift implementation of each lives in
/// `ios/glassy_ui_ios/Sources/glassy_ui_ios/Components/`, and
/// its doc comment lists the [NativeComponentConfig] fields, commands and
/// events it supports.
enum NativeComponentType {
  /// Navigation bar with leading/trailing actions.
  ///
  /// * `title`: bar title (default "Inbox")
  /// * `items`: list rows
  /// * `extra.leading` / `extra.trailing`: button titles or SF Symbols
  /// * Events: `tap(String)`, `select(itemId)`
  navBar(
      'nav-bar',
      'Navigation Bar / App Bar',
      NativeComponentCategory.navigation,
      'NavigationStack + .toolbar — glass bar on iOS 26',
      null),

  /// Pushed page with the system back button.
  ///
  /// * `title`: root title (default "Library"); `subtitle`: pushed page title
  /// * Commands: `trigger` pushes a page
  /// * Events: `push(String)`, `back(String)`
  backButton('back-button', 'Back Button', NativeComponentCategory.navigation,
      'NavigationStack(path:) system back button', 'Push page'),

  /// Close buttons: system close role, glass and prominent glass.
  ///
  /// * `title`: modal title (default "Modal"); `message`: modal body text
  /// * Commands: `trigger` opens the modal
  /// * Events: `close(String source)`
  closeButton(
      'close-button',
      'Close Button',
      NativeComponentCategory.navigation,
      'Button(role: .close) / xmark.circle.fill',
      'Open modal'),

  /// Inline title with a subtitle and a title menu.
  ///
  /// * `title`: initial title; `subtitle`: caption under the title
  /// * `extra.menu`: title menu options (default folders)
  /// * Events: `titleMenu(String)`
  navTitle('nav-title', 'Navigation Title', NativeComponentCategory.navigation,
      '.navigationTitle + .toolbarTitleMenu', null),

  /// Large title that collapses on scroll.
  ///
  /// * `title` (default "Large Title"), `image`: trailing button icon
  /// * Events: `tap("add")`, `select(itemId)`
  largeNavTitle(
      'large-nav-title',
      'Large Navigation Title',
      NativeComponentCategory.navigation,
      '.navigationBarTitleDisplayMode(.large)',
      null),

  /// Toolbar with grouped trailing actions separated by a `ToolbarSpacer` (iOS 26).
  ///
  /// * `title`; `items`: grouped trailing actions (default share / favorite)
  /// * Events: `tap(itemId)`, `menu(String)`
  toolbar('toolbar', 'Toolbar', NativeComponentCategory.navigation,
      'ToolbarItemGroup + ToolbarSpacer (iOS 26)', null),

  /// Floating glass toolbar with toggleable tools, split into two glass groups.
  ///
  /// * `items`: tools (default text formatting). Items with `selected` start on.
  /// * `extra.split`: how many tools go in the first group (default 4)
  /// * Events: `toggle({tool, on})`
  floatingToolbar(
      'floating-toolbar',
      'Floating Toolbar',
      NativeComponentCategory.navigation,
      'GlassEffectContainer + .glassEffect / material capsule',
      null),

  /// Bottom toolbar with a status label.
  ///
  /// * `title`, `subtitle`: status text (default "30 Notes")
  /// * `items`: first two items become the leading/trailing buttons
  /// * Events: `tap(itemId)`
  bottomToolbar(
      'bottom-toolbar',
      'Bottom Toolbar',
      NativeComponentCategory.navigation,
      'ToolbarItem(placement: .bottomBar)',
      null),

  /// Form with Cancel and a prominent confirm action.
  ///
  /// * `title` (default "New Event"), `value`: initial text, `placeholder`
  /// * `image`: confirm icon (default checkmark)
  /// * Events: `cancel`, `save(String)`
  toolbarActionButton(
      'toolbar-action-button',
      'Toolbar Action Button',
      NativeComponentCategory.navigation,
      '.confirmationAction + .glassProminent',
      null),

  /// Glass buttons in every control size.
  ///
  /// * `title`: button text (default "Glass"); `image`: optional icon
  /// * `items`: custom buttons instead of the size showcase
  glassButton('glass-button', 'Glass Button', NativeComponentCategory.buttons,
      '.buttonStyle(.glass) / .bordered', null),

  /// Prominent (filled) glass buttons, one per tint.
  ///
  /// * `title` (default "Continue"), `image` (default arrow.right)
  /// * `extra.tints`: list of ARGB ints; defaults to blue/green/orange/pink
  prominentGlassButton(
      'prominent-glass-button',
      'Prominent Glass Button',
      NativeComponentCategory.buttons,
      '.buttonStyle(.glassProminent) / .borderedProminent',
      null),

  /// Grid of image buttons with a glass play badge.
  ///
  /// * `items`: tiles; each item's `image` is the artwork (asset/bytes recommended)
  /// * `image`: badge icon (default play.fill); `style.cornerRadius` for tiles
  /// * Events: `tap(itemId)`
  imageButton('image-button', 'Image Button', NativeComponentCategory.buttons,
      'Button with image label + custom ButtonStyle', null),

  /// Circular icon buttons, both glass button style and interactive glass circles.
  ///
  /// * `items`: icons (default communication symbols)
  /// * Events: `tap(itemId)`
  circularIconButton(
      'circular-icon-button',
      'Circular Icon Button',
      NativeComponentCategory.buttons,
      '.buttonBorderShape(.circle) + glass',
      null),

  /// SF Symbol buttons with effects: bounce, replace, variable value and palette.
  ///
  /// * `image`: symbol used for the bounce button (default bell.badge.fill)
  /// * Events: `bounce`, `liked(Bool)`, `variableValue(Double)`, `tap(String)`
  sfSymbolsButton(
      'sf-symbols-button',
      'SF Symbols Button',
      NativeComponentCategory.buttons,
      '.symbolEffect, rendering modes, variableValue',
      null),

  /// Large glass plus button driving a counter.
  ///
  /// * `value`: initial count (default 5); `min` / `max`: bounds; `step`: delta
  /// * Commands: `trigger` applies one step, `reset` restores `value`
  /// * Events: `increment(Int)`, `decrement(Int)`
  plusButton('plus-button', 'Plus Button', NativeComponentCategory.buttons,
      'Glass circle + .numericText transition', 'Increment'),

  /// Large glass minus button driving a counter.
  ///
  /// * `value`: initial count (default 5); `min` / `max`: bounds; `step`: delta
  /// * Commands: `trigger` applies one step, `reset` restores `value`
  /// * Events: `increment(Int)`, `decrement(Int)`
  minusButton('minus-button', 'Minus Button', NativeComponentCategory.buttons,
      'Glass circle + .numericText transition', 'Decrement'),

  /// Floating action button that morphs into a stack of actions.
  ///
  /// * `image`: FAB icon (default plus); `items`: actions
  /// * Commands: `trigger` toggles; Events: `fab(String)`, `action(itemId)`
  floatingActionButton(
      'floating-action-button',
      'Floating Action Button',
      NativeComponentCategory.buttons,
      'Glass morphing with glassEffectID',
      'Toggle FAB'),

  /// Toolbar avatar that opens an account menu.
  ///
  /// * `title`: initials (default "RP"); `image`: avatar picture (asset/bytes)
  /// * `items`: menu actions (`role: destructive` supported)
  /// * Events: `menu(itemId)`
  avatarActionButton('avatar-action-button', 'Avatar Action Button',
      NativeComponentCategory.buttons, 'Toolbar Menu with avatar label', null),

  /// Segmented picker driving a small bar chart.
  ///
  /// * `items`: segments (default Day/Week/Month/Year); `value`: selected item id
  /// * Events: `change(itemId)`
  segmentedControl('segmented-control', 'Segmented Control',
      NativeComponentCategory.controls, 'Picker(.segmented)', null),

  /// List of switches.
  ///
  /// * `items`: switches; `selected` sets the initial state
  /// * Commands: `trigger` toggles the first switch
  /// * Events: `change({id, on})`
  toggle('toggle', 'Toggle / Switch', NativeComponentCategory.controls,
      'Toggle(.switch)', 'Toggle Wi-Fi'),

  /// Stepper.
  ///
  /// * `title`: label prefix (default "Quantity"); `value`, `min`, `max`, `step`
  /// * Events: `change(Double)`
  stepper('stepper', 'Stepper', NativeComponentCategory.controls,
      'Stepper(value:in:step:)', null),

  /// Slider with min/max icons.
  ///
  /// * `title`, `value` (0.6), `min`/`max` (0…1), `step`
  /// * `extra.minImage` / `extra.maxImage`: SF Symbol names
  /// * Commands: `trigger` sets a random value
  /// * Events: `change(Double)` when dragging ends
  slider('slider', 'Slider', NativeComponentCategory.controls,
      'Slider with min/max value labels', 'Random value'),

  /// Stepped slider with tick marks (native ticks on iOS 26, drawn before).
  ///
  /// * `title`, `value` (1), `min`/`max` (0.5…2), `step` (0.25)
  /// * `extra.labels`: captions under the track
  /// * Events: `change(Double)`
  sliderTicks(
      'slider-ticks',
      'Slider with Tick Marks',
      NativeComponentCategory.controls,
      'Slider(tick:) iOS 26 / drawn ticks',
      null),

  /// Paged carousel with a page indicator.
  ///
  /// * `items`: pages (each item's `image` is the artwork); `value`: initial page
  /// * Commands: `trigger` goes to the next page
  /// * Events: `change(Int)`
  pageIndicator(
      'page-indicator',
      'Page Indicator',
      NativeComponentCategory.controls,
      'TabView(.page) + .indexViewStyle',
      'Next page'),

  /// Checklist using a circular checkbox `ToggleStyle`.
  ///
  /// * `title` (default "Reminders"); `items` with `selected` as checked state
  /// * Events: `change({id, checked})`
  checkbox(
      'checkbox',
      'Checkbox-Style Control',
      NativeComponentCategory.controls,
      'Custom ToggleStyle with SF Symbols',
      null),

  /// Standard tab bar.
  ///
  /// * `items`: tabs; `value`: initial tab id
  /// * Commands: `trigger` selects the next tab; Events: `change(itemId)`
  tabBar('tab-bar', 'Tab Bar', NativeComponentCategory.structure,
      'TabView + .tabItem', 'Next tab'),

  /// Floating tab bar: native minimize-on-scroll on iOS 26, custom glass capsule before.
  ///
  /// * `items`: tabs; Events: `change(itemId)`
  floatingTabBar(
      'floating-tab-bar',
      'Floating Tab Bar',
      NativeComponentCategory.structure,
      '.tabBarMinimizeBehavior(.onScrollDown) / custom capsule',
      null),

  /// Tab items with symbols, titles and badges.
  ///
  /// * `items`: tabs (use `badge`); `message`: body text of the first tab
  /// * Events: `change(itemId)`, `badge(Int)`
  tabBarItem('tab-bar-item', 'Tab Bar Item', NativeComponentCategory.structure,
      '.tabItem + .badge', null),

  /// Glass tab capsules where the selected tab expands to show its title.
  ///
  /// * `items`: tabs; `value`: initial tab id; Events: `change(itemId)`
  expandableTabBar(
      'expandable-tab-bar',
      'Expandable Tab Bar',
      NativeComponentCategory.structure,
      'Glass capsules that expand with glassEffectID',
      null),

  /// Tab bar with a dedicated search tab (`Tab(role: .search)` on iOS 18+).
  ///
  /// * `items`: regular tabs; `placeholder`: search prompt
  /// * `extra.results`: searchable strings
  /// * Events: `change(itemId)`, `search(String)`
  searchTab('search-tab', 'Search Tab', NativeComponentCategory.structure,
      'Tab(role: .search) iOS 18+ / tabItem', null),

  /// Sidebar navigation (`NavigationSplitView` + `.sidebar` list).
  ///
  /// * `title` (default "Mailboxes"); `items`: sidebar rows; `message`: detail text
  /// * Events: `change(itemId)`
  sidebar('sidebar', 'Sidebar', NativeComponentCategory.structure,
      'NavigationSplitView + .listStyle(.sidebar)', null),

  /// Programmatic `NavigationStack(path:)` with push and pop to root.
  ///
  /// * `title`: root title; `extra.pushLabel` / `extra.popLabel`
  /// * Commands: `trigger` pushes, `reset` pops to root
  /// * Events: `change(String path)`
  navigationStack(
      'navigation-stack',
      'Navigation Stack',
      NativeComponentCategory.structure,
      'NavigationStack(path:) + navigationDestination',
      'Push level'),

  /// Three-column split view: categories → items → detail.
  ///
  /// * `items`: categories whose `children` are the items
  /// * Events: `category(itemId)`, `item(itemId)`
  splitView('split-view', 'Split View', NativeComponentCategory.structure,
      'Three-column NavigationSplitView', null),

  /// Accessory above the tab bar (`tabViewBottomAccessory` on iOS 26).
  ///
  /// * `title` / `subtitle` / `image`: now playing info; `items`: tabs
  /// * Events: `playback(String)`
  floatingAccessory(
      'floating-accessory',
      'Floating Accessory View',
      NativeComponentCategory.structure,
      '.tabViewBottomAccessory (iOS 26) / safeAreaInset',
      null),

  /// Inspector panel editing a shape (`.inspector`, a sheet on iPhone).
  ///
  /// * `title` (default "Canvas"); `style.cornerRadius`/`tintColor` seed the shape
  /// * Commands: `trigger` toggles the inspector
  /// * Events: `inspector(String)`, `change({color, opacity, corner})`
  inspector('inspector', 'Inspector Panel', NativeComponentCategory.structure,
      '.inspector(isPresented:)', 'Toggle inspector'),

  /// Persistent Maps-style sheet that allows interacting with the content behind it.
  ///
  /// * `title`, `placeholder` (header text), `items`
  /// * `extra.detents`: detent names (default ["120pt", "medium", "large"])
  /// * Events: `presented`, `dismissed`, `detent(String)`, `select(itemId)`
  bottomSheet(
      'bottom-sheet',
      'Bottom Sheet',
      NativeComponentCategory.presentation,
      'Sheet with .height detent + background interaction',
      'Toggle sheet'),

  /// Half-height sheet (`.medium` detent).
  ///
  /// * `title`, `items`; Events: `presented`, `dismissed`, `select(itemId)`
  halfSheet(
      'half-sheet',
      'Half-Screen Sheet',
      NativeComponentCategory.presentation,
      '.presentationDetents([.medium])',
      'Present'),

  /// Full-screen cover with a close button.
  ///
  /// * `title`, `message`; Events: `presented`, `dismissed`
  fullSheet('full-sheet', 'Full-Screen Sheet',
      NativeComponentCategory.presentation, '.fullScreenCover', 'Present'),

  /// Sheet with several detents and buttons to jump between them.
  ///
  /// * `extra.detents` (default ["0.25", "medium", "large"])
  /// * Events: `detent(String)`
  detentedSheet(
      'detented-sheet',
      'Detented Sheet',
      NativeComponentCategory.presentation,
      'Detents with selection binding',
      'Present'),

  /// Sheet with a configurable drag indicator.
  ///
  /// * `value`: initial indicator visibility (default true); `title`, `message`
  /// * Events: `indicator(Bool)`, `presented`, `dismissed`
  dragIndicator(
      'drag-indicator',
      'Sheet Drag Indicator',
      NativeComponentCategory.presentation,
      '.presentationDragIndicator',
      'Present'),

  /// Alert with role-aware buttons, plus an alert with a text field.
  ///
  /// * `title`, `message`, `items`: alert buttons (roles supported)
  /// * `placeholder`: text field prompt
  /// * Events: `action(itemId)`, `rename(String)`
  alert('alert', 'Alert Dialog', NativeComponentCategory.presentation,
      '.alert with roles + text field', 'Show alert'),

  /// Confirmation dialog (a popover anchored to its button on iOS 26).
  ///
  /// * `title`, `message`, `items` (roles supported); Events: `action(itemId)`
  confirmationDialog(
      'confirmation-dialog',
      'Confirmation Dialog',
      NativeComponentCategory.presentation,
      '.confirmationDialog — popover on iOS 26',
      'Show dialog'),

  /// UIKit action sheet (`UIAlertController(.actionSheet)`).
  ///
  /// * `title`, `message`, `items` (roles map to UIAlertAction styles)
  /// * Events: `action(itemId)`
  actionSheet(
      'action-sheet',
      'Action Sheet',
      NativeComponentCategory.presentation,
      'UIKit UIAlertController(.actionSheet)',
      'Show sheet'),

  /// Popover that stays a popover on iPhone (`presentationCompactAdaptation`).
  ///
  /// * `title`: button title, `image`: button icon, `items`: popover options
  /// * Events: `select(itemId)`
  popover('popover', 'Popover', NativeComponentCategory.presentation,
      '.popover + .presentationCompactAdaptation', 'Show popover'),

  /// Glass toast that slides in from the top and auto-dismisses.
  ///
  /// * `title`: message; `image`: icon (default checkmark.circle.fill)
  /// * `extra.duration`: seconds on screen (default 2.2)
  /// * `extra.position`: "top" | "bottom"
  /// * Commands: `trigger` shows the toast (arguments: optional message)
  /// * Events: `shown(String)`, `dismissed`
  toast(
      'toast',
      'Toast / Notification Overlay',
      NativeComponentCategory.presentation,
      'Glass capsule overlay with transition',
      'Show toast'),

  /// Custom centered glass confirmation card with a dimmed backdrop.
  ///
  /// * `title`, `message`, `image` (default checkmark.seal.fill)
  /// * `items`: two buttons (cancel, confirm)
  /// * Events: `result(itemId | "dismiss")`
  confirmationPopup(
      'confirmation-popup',
      'Confirmation Popup',
      NativeComponentCategory.presentation,
      'Custom glass card modal',
      'Show popup'),

  /// Pop-up button showing the current choice.
  ///
  /// * `title`: row label (default "Repeat"); `items`: options; `value`: selected id
  /// * Events: `change(itemId)`
  popupMenu('popup-menu', 'Popup Menu', NativeComponentCategory.menus,
      'Menu + Picker (pop-up button)', null),

  /// Dropdown with a sort picker section and an "ascending" toggle.
  ///
  /// * `title` (default "Sort"), `image`, `items`: sort options; `value`: selected id
  /// * Events: `change(itemId)`, `ascending(Bool)`
  dropdownMenu('dropdown-menu', 'Dropdown Menu', NativeComponentCategory.menus,
      'Menu with sections, Picker and Toggle', null),

  /// Long-press context menu with preview on image tiles.
  ///
  /// * `title`: hint text; `items`: tiles (their `image` is the artwork)
  /// * `extra.actions`: action titles (default Copy/Favorite/Delete; "Delete" is destructive)
  /// * Events: `action({item, action})`
  contextMenu('context-menu', 'Context Menu', NativeComponentCategory.menus,
      '.contextMenu with preview', null),

  /// Toolbar overflow (ellipsis) menu.
  ///
  /// * `title`: navigation title; `items`: menu entries; `image`: menu icon
  /// * Events: `select(itemId)`
  overflowMenu('overflow-menu', 'Overflow Menu', NativeComponentCategory.menus,
      'Toolbar Menu with ellipsis', null),

  /// Menu with nested submenus built from `items[].children`.
  ///
  /// * `title` (default "File"), `image`, `items` (nest with `children`)
  /// * Events: `select(itemId)`
  nestedSubmenu('nested-submenu', 'Nested Submenu',
      NativeComponentCategory.menus, 'Menu inside Menu', null),

  /// SwiftUI `ShareLink` plus UIKit `UIActivityViewController` with a completion callback.
  ///
  /// * `title`: share text; `message`: subject; `extra.url`: URL to share
  /// * Commands: `trigger` opens the activity sheet
  /// * Events: `shareLink`, `completed({activity, completed})`
  shareMenu('share-menu', 'Share Menu', NativeComponentCategory.menus,
      'ShareLink + UIActivityViewController', 'Share'),

  /// `UITextView` whose edit menu has custom actions sending the selection to Dart.
  ///
  /// * `message`: the text; `items`: custom menu actions (default Send / Highlight)
  /// * Events: `<itemId>(String selectedText)`
  textSelectionMenu('text-selection-menu', 'Text Selection Menu',
      NativeComponentCategory.menus, 'UITextView editMenuForTextIn', null),

  /// Rounded, glass and chat-style text fields.
  ///
  /// * `placeholder`, `value`: initial text; `extra.keyboard`: "email" | "number" | "url" | "default"
  /// * Events: `submit(String)`, `send(String)`
  textField('text-field', 'Text Field', NativeComponentCategory.input,
      'TextField styles + glass field', null),

  /// Password field with reveal toggle and strength meter. Only the length and
  /// strength are sent to Dart, never the password itself, unless `extra.emitText`.
  ///
  /// * `placeholder`; `extra.emitText`: include the text in `submit`
  /// * Events: `submit({length, strength, text?})`, `strength(String)`
  secureField(
      'secure-field',
      'Secure Password Field',
      NativeComponentCategory.input,
      'SecureField with reveal + strength',
      null),

  /// Navigation-bar search field with suggestions and filtering.
  ///
  /// * `title`, `placeholder`, `items`: searchable rows, `extra.suggestions`
  /// * Events: `search(String)`, `select(itemId)`
  searchField('search-field', 'Search Field', NativeComponentCategory.input,
      '.searchable + .searchSuggestions', null),

  /// Multiline `TextEditor` in a glass card with a character counter.
  ///
  /// * `title`, `value`: initial text; `max`: character limit
  /// * Events: `done({characters, text})`
  textEditor('text-editor', 'Multiline Text Editor',
      NativeComponentCategory.input, 'TextEditor + FocusState', null),

  /// Graphical and compact date pickers.
  ///
  /// * `title`, `value`: ISO-8601 date; `extra.style`: "graphical" | "compact" | "wheel"
  /// * Events: `change(ISO-8601 String)`
  datePicker('date-picker', 'Date Picker', NativeComponentCategory.input,
      'DatePicker(.graphical / .compact)', null),

  /// Wheel and compact time pickers.
  ///
  /// * `title`, `value`: ISO-8601 date-time
  /// * Events: `change({hour, minute, iso})`
  timePicker('time-picker', 'Time Picker', NativeComponentCategory.input,
      'DatePicker(.hourAndMinute, .wheel)', null),

  /// Multi-column wheel picker. Columns are `items`, each with `children` as rows.
  ///
  /// * `items`: columns (default hours/minutes); `value`: list of selected row ids
  /// * Events: `change([String])`
  wheelPicker('wheel-picker', 'Wheel Picker', NativeComponentCategory.input,
      'Picker(.wheel) multi-column', null),

  /// Menu-style picker, standalone and inside a Form.
  ///
  /// * `title`, `items`: options, `value`: selected id; Events: `change(itemId)`
  menuPicker('menu-picker', 'Menu Picker', NativeComponentCategory.input,
      'Picker(.menu)', null),

  /// System color picker with a live swatch.
  ///
  /// * `title`, `value`: initial ARGB int; `extra.supportsOpacity` (default true)
  /// * Events: `change({hex, argb})`
  colorPicker('color-picker', 'Color Picker', NativeComponentCategory.input,
      'ColorPicker (returns hex to Dart)', null),

  /// Floating glass search capsule with a trailing button that hides while typing.
  ///
  /// * `title`: page title; `placeholder`; `image`: trailing button icon (default mic.fill)
  /// * Commands: `trigger` focuses the field
  /// * Events: `search(String)`, `tap("accessory")`
  floatingSearchBar(
      'floating-search-bar',
      'Floating Search Bar',
      NativeComponentCategory.input,
      'Glass search capsule over content',
      'Focus search'),

  /// Capacity gauge and gradient ring.
  ///
  /// * `title`, `value`: 0…1 (simulated if unset); `style.tintColor`
  /// * `extra.lineWidth`: ring width (default 12)
  /// * Events: `complete`
  circularProgress(
      'circular-progress',
      'Circular Progress Indicator',
      NativeComponentCategory.progress,
      'Gauge(.accessoryCircularCapacity) + ring',
      'Restart'),

  /// Linear progress bars.
  ///
  /// * `title`, `value`: 0…1 (simulated if unset); `extra.height`: bar thickness scale
  /// * Events: `complete`
  linearProgress('linear-progress', 'Linear Progress Bar',
      NativeComponentCategory.progress, 'ProgressView(value:)', 'Restart'),

  /// Step-based progress with Back / Next.
  ///
  /// * `title`, `value`: current step (default 2), `max`: total steps (default 5)
  /// * Commands: `trigger` next, `reset` to zero; Events: `change(Int)`
  determinateProgress(
      'determinate-progress',
      'Determinate Progress Bar',
      NativeComponentCategory.progress,
      'ProgressView(value:total:) + Gauge',
      'Next step'),

  /// Spinners plus an animated indeterminate bar.
  ///
  /// * `title`: spinner label (default "Loading…")
  indeterminateLoading(
      'indeterminate-loading',
      'Indeterminate Loading Indicator',
      NativeComponentCategory.progress,
      'ProgressView() + animated bar',
      null),

  /// App Store-style download button: ring with stop/resume, then "OPEN".
  ///
  /// * `title`: app name, `subtitle`: size text, `image`: app icon
  /// * `extra.openTitle` (default "OPEN"), `extra.speed`
  /// * Commands: `trigger` start/pause, `reset`
  /// * Events: `start(Int)`, `pause(Int)`, `progress(25|50|75|100)`, `complete`, `open`
  downloadProgress(
      'download-progress',
      'Download Progress Indicator',
      NativeComponentCategory.progress,
      'App Store-style ring button',
      'Start / pause'),

  /// Multiple uploads, each with its own progress bar.
  ///
  /// * `title`; `items`: files (title = file name); `extra.speed`
  /// * Commands: `trigger` / `reset` restart; Events: `uploaded(itemId)`, `complete`
  uploadProgress('upload-progress', 'Upload Progress Indicator',
      NativeComponentCategory.progress, 'Per-file ProgressView', 'Restart'),

  /// UIKit `UIActivityIndicatorView` in medium, large and tinted styles.
  ///
  /// * `title`, `value`: animating (default true); `style.tintColor` colors the third spinner
  /// * Commands: `trigger` toggles; Events: `change(Bool)`
  activityIndicator(
      'activity-indicator',
      'Activity Indicator',
      NativeComponentCategory.progress,
      'UIKit UIActivityIndicatorView',
      'Toggle'),

  /// Photo grid with selection mode and a bottom glass toolbar.
  ///
  /// * `title` (default "Library"); `items`: photos (`image` = artwork)
  /// * `extra.count`: number of placeholder photos when `items` is empty (default 45)
  /// * Events: `open(itemId)`, `selecting(Bool)`, `share([ids])`, `delete([ids])`
  galleryToolbar(
      'gallery-toolbar',
      'Gallery Toolbar',
      NativeComponentCategory.media,
      'Grid + bottomBar selection toolbar',
      null),

  /// Full-screen photo with glass top and bottom chrome; tap to hide chrome.
  ///
  /// * `image`: the photo; `title` / `subtitle`: date and time
  /// * `items`: center bottom actions (default favorite, info, edit)
  /// * Events: `tap(String)`, `favorite(Bool)`
  photoViewerToolbar('photo-viewer-toolbar', 'Photo Viewer Toolbar',
      NativeComponentCategory.media, 'Glass top/bottom chrome', null),

  /// Now-playing card: artwork, scrubber, transport and volume.
  ///
  /// * `title`, `subtitle`, `image`: track info; `value`: position 0…1
  /// * `max`: track length in seconds (default 215)
  /// * Commands: `trigger` play/pause
  /// * Events: `play`, `pause`, `previous`, `next`, `seek(Int seconds)`, `volume(Double)`
  mediaControls('media-controls', 'Media Playback Controls',
      NativeComponentCategory.media, 'Now Playing glass card', 'Play / pause'),

  /// Large glass play/pause toggle with symbol replace transition.
  ///
  /// * `value`: initial playing state; `extra.size`: diameter (default 110)
  /// * Commands: `trigger` toggles; Events: `play`, `pause`
  playPause('play-pause', 'Play / Pause Button', NativeComponentCategory.media,
      '.contentTransition(.symbolEffect(.replace))', 'Play / pause'),

  /// Skip backward / forward buttons with bounce effect.
  ///
  /// * `value`: start position in seconds (default 60)
  /// * `extra.back` / `extra.forward`: skip intervals (10, 15, 30, 45…; default 15 / 30)
  /// * Events: `skipBackward(Int)`, `skipForward(Int)`
  skipButtons(
      'skip-buttons',
      'Skip Forward / Backward Button',
      NativeComponentCategory.media,
      'gobackward.15 / goforward.30 + bounce',
      null),

  /// App volume slider plus the system `MPVolumeView` (device only).
  ///
  /// * `title`, `value`: 0…1 (default 0.5); `extra.showSystem` (default true)
  /// * Events: `change(Double)`
  volumeSlider('volume-slider', 'Volume Slider', NativeComponentCategory.media,
      'Slider + MPVolumeView', null),

  /// Full-screen media with glass close and minimize buttons.
  ///
  /// * `image`: media artwork; `extra.showMinimize` (default true)
  /// * Events: `close("xmark" | "minimize")`
  mediaClose('media-close', 'Full-Screen Media Close Button',
      NativeComponentCategory.media, 'Glass xmark over media', null),

  /// Picture-in-picture style mini player that can be dragged to any corner.
  /// Reports whether system PiP (`AVPictureInPictureController`) is supported.
  ///
  /// * `title`: list title; `image`: video artwork
  /// * Commands: `trigger` toggles PiP
  /// * Events: `pip({active, systemSupported})`, `snap(String corner)`, `close`
  pipControls(
      'pip-controls',
      'Picture-in-Picture Controls',
      NativeComponentCategory.media,
      'Draggable mini player + AVKit support check',
      'Toggle PiP'),

  /// Camera chrome: flash, live photo, mode carousel, shutter and flip.
  /// UI only — no camera session is started (no permission prompt).
  ///
  /// * `image`: viewfinder preview; `items`: modes (default iOS camera modes); `value`: initial mode id
  /// * Events: `flash(Bool)`, `mode(itemId)`, `capture({mode, count})`, `flip`, `tap("live")`
  cameraControls('camera-controls', 'Camera Controls',
      NativeComponentCategory.media, 'Shutter, modes, flash, flip', null),

  /// Camera zoom pills plus pinch to zoom.
  ///
  /// * `image`: preview; `extra.presets`: zoom levels (default [0.5, 1, 2, 5]); `value`: initial zoom
  /// * `max`: max zoom (default 10)
  /// * Events: `change(Double)`
  zoomControls('zoom-controls', 'Zoom Controls', NativeComponentCategory.media,
      'Zoom pills + MagnifyGesture', null),

  /// Crop editor: aspect ratios, straighten dial, rotate and flip.
  ///
  /// * `image`: photo; `items`: aspect ratios where `id` is "w:h" or "free"
  /// * Events: `aspect(itemId)`, `rotate(Int)`, `flip(Bool)`, `done({angle, aspect})`
  cropControls('crop-controls', 'Crop Controls', NativeComponentCategory.media,
      'Aspect ratios, straighten dial, rotate', null),

  /// Scroll content under the bar with a soft/hard scroll-edge effect.
  ///
  /// * `title`; `value`: "soft" | "hard"; `items`: cards (`image` = artwork)
  /// * Events: `change(String)`
  scrollEdge(
      'scroll-edge',
      'Scroll-Edge Glass Effect',
      NativeComponentCategory.glass,
      '.scrollEdgeEffectStyle(.soft / .hard)',
      null),

  /// Regular, clear and tinted glass panels.
  ///
  /// * `items`: panels — `title`, `subtitle`; `id` "clear…" uses clear glass
  /// * `style.glassTint` tints the tinted samples
  glassBackground('glass-background', 'Glass Background',
      NativeComponentCategory.glass, 'Glass.regular / .clear / .tint', null),

  /// Glass applied to built-in and custom shapes.
  ///
  /// * `items`: shapes; `id` is the shape name (circle, capsule, rounded, ellipse, star, blob)
  /// * `extra.size`: tile size (default 130); Events: `tap(itemId)`
  customGlassShape('custom-glass-shape', 'Custom Glass Shape',
      NativeComponentCategory.glass, '.glassEffect(in: customShape)', null),

  /// Segmented-looking group of glass buttons merged with `glassEffectUnion`.
  ///
  /// * `items`: grouped buttons (default text alignment); `value`: selected id
  /// * Events: `change(itemId)`, `tap(String)`
  glassButtonGroup('glass-button-group', 'Glass Button Group',
      NativeComponentCategory.glass, '.glassEffectUnion', null),

  /// Glass circles in one `GlassEffectContainer` that blend as they approach.
  ///
  /// * `items`: circles (`image` = icon); `value`: spacing (default 40); `min`/`max` slider range
  /// * Events: `change(Int spacing)`
  glassContainer(
      'glass-container',
      'Glass Effect Container',
      NativeComponentCategory.glass,
      'GlassEffectContainer(spacing:) blending',
      null),

  /// A button that morphs into a column of tool buttons (`glassEffectID`).
  ///
  /// * `image`: toggle icon; `items`: tools; `value`: start expanded
  /// * Commands: `trigger` toggles; Events: `expanded`, `collapsed`, `select(itemId)`
  glassMorphing('glass-morphing', 'Glass Morphing Animation',
      NativeComponentCategory.glass, '.glassEffectID morphing', 'Morph'),

  /// Show/hide glass elements with `.materialize` or `.matchedGeometry` transitions.
  ///
  /// * `items`: badges (`image` = icon); `value`: "materialize" | "matchedGeometry"
  /// * Commands: `trigger` toggles; Events: `shown(String)`, `hidden(String)`
  glassTransition(
      'glass-transition',
      'Glass Transition',
      NativeComponentCategory.glass,
      '.glassEffectTransition(.materialize)',
      'Show / hide'),

  /// App icon with layered glass styling across Default / Dark / Clear / Tinted.
  ///
  /// * `image`: foreground symbol or bitmap; `items`: home-screen icons
  /// * `value`: initial appearance name; `style.backgroundGradient`: icon background
  /// * `style.glassTint`: tinted mode color
  /// * Events: `change(String)`
  appIcon(
      'app-icon',
      'App Icon with Layered Glass Styling',
      NativeComponentCategory.glass,
      'Layered icon: default / dark / clear / tinted',
      null),

  /// Small and medium widgets previewed in each rendering mode.
  ///
  /// * `title` / `subtitle` / `message`: medium widget texts; `value`: appearance name
  /// * `extra.city`, `extra.temperature`, `extra.battery` (0…1)
  /// * Events: `change(String)`
  widgetAppearance(
      'widget-appearance',
      'Widget with Clear or Tinted Appearance',
      NativeComponentCategory.glass,
      'Full colour / clear / tinted rendering',
      null);

  const NativeComponentType(
      this.id, this.title, this.category, this.nativeApi, this.triggerLabel);

  /// Identifier registered on the native side.
  final String id;

  /// Human readable name.
  final String title;

  /// Catalog category.
  final NativeComponentCategory category;

  /// Native API used (iOS 26 path / classic fallback).
  final String nativeApi;

  /// What `NativeComponentController.trigger()` does, or `null` if unsupported.
  final String? triggerLabel;

  /// Looks up a type by its native [id].
  static NativeComponentType? byId(String id) {
    for (final type in values) {
      if (type.id == id) return type;
    }
    return null;
  }
}
