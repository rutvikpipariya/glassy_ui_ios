/// Grouping used for catalogs and documentation.
enum NativeComponentCategory {
  navigation('Navigation & Toolbars'),
  buttons('Buttons'),
  controls('Controls'),
  structure('Tabs & Structure'),
  presentation('Sheets, Dialogs & Overlays'),
  menus('Menus'),
  input('Input & Pickers'),
  progress('Progress'),
  media('Media & Camera'),
  glass('Liquid Glass');

  const NativeComponentCategory(this.title);

  final String title;
}

/// Every built-in native component.
///
/// The Swift implementation of each lives in
/// `ios/glassy_ui_ios/Sources/glassy_ui_ios/Components/`, and
/// its doc comment lists the [NativeComponentConfig] fields, commands and
/// events it supports.
enum NativeComponentType {
  navBar(
      'nav-bar',
      'Navigation Bar / App Bar',
      NativeComponentCategory.navigation,
      'NavigationStack + .toolbar — glass bar on iOS 26',
      null),
  backButton('back-button', 'Back Button', NativeComponentCategory.navigation,
      'NavigationStack(path:) system back button', 'Push page'),
  closeButton(
      'close-button',
      'Close Button',
      NativeComponentCategory.navigation,
      'Button(role: .close) / xmark.circle.fill',
      'Open modal'),
  navTitle('nav-title', 'Navigation Title', NativeComponentCategory.navigation,
      '.navigationTitle + .toolbarTitleMenu', null),
  largeNavTitle(
      'large-nav-title',
      'Large Navigation Title',
      NativeComponentCategory.navigation,
      '.navigationBarTitleDisplayMode(.large)',
      null),
  toolbar('toolbar', 'Toolbar', NativeComponentCategory.navigation,
      'ToolbarItemGroup + ToolbarSpacer (iOS 26)', null),
  floatingToolbar(
      'floating-toolbar',
      'Floating Toolbar',
      NativeComponentCategory.navigation,
      'GlassEffectContainer + .glassEffect / material capsule',
      null),
  bottomToolbar(
      'bottom-toolbar',
      'Bottom Toolbar',
      NativeComponentCategory.navigation,
      'ToolbarItem(placement: .bottomBar)',
      null),
  toolbarActionButton(
      'toolbar-action-button',
      'Toolbar Action Button',
      NativeComponentCategory.navigation,
      '.confirmationAction + .glassProminent',
      null),
  glassButton('glass-button', 'Glass Button', NativeComponentCategory.buttons,
      '.buttonStyle(.glass) / .bordered', null),
  prominentGlassButton(
      'prominent-glass-button',
      'Prominent Glass Button',
      NativeComponentCategory.buttons,
      '.buttonStyle(.glassProminent) / .borderedProminent',
      null),
  imageButton('image-button', 'Image Button', NativeComponentCategory.buttons,
      'Button with image label + custom ButtonStyle', null),
  circularIconButton(
      'circular-icon-button',
      'Circular Icon Button',
      NativeComponentCategory.buttons,
      '.buttonBorderShape(.circle) + glass',
      null),
  sfSymbolsButton(
      'sf-symbols-button',
      'SF Symbols Button',
      NativeComponentCategory.buttons,
      '.symbolEffect, rendering modes, variableValue',
      null),
  plusButton('plus-button', 'Plus Button', NativeComponentCategory.buttons,
      'Glass circle + .numericText transition', 'Increment'),
  minusButton('minus-button', 'Minus Button', NativeComponentCategory.buttons,
      'Glass circle + .numericText transition', 'Decrement'),
  floatingActionButton(
      'floating-action-button',
      'Floating Action Button',
      NativeComponentCategory.buttons,
      'Glass morphing with glassEffectID',
      'Toggle FAB'),
  avatarActionButton('avatar-action-button', 'Avatar Action Button',
      NativeComponentCategory.buttons, 'Toolbar Menu with avatar label', null),
  segmentedControl('segmented-control', 'Segmented Control',
      NativeComponentCategory.controls, 'Picker(.segmented)', null),
  toggle('toggle', 'Toggle / Switch', NativeComponentCategory.controls,
      'Toggle(.switch)', 'Toggle Wi-Fi'),
  stepper('stepper', 'Stepper', NativeComponentCategory.controls,
      'Stepper(value:in:step:)', null),
  slider('slider', 'Slider', NativeComponentCategory.controls,
      'Slider with min/max value labels', 'Random value'),
  sliderTicks(
      'slider-ticks',
      'Slider with Tick Marks',
      NativeComponentCategory.controls,
      'Slider(tick:) iOS 26 / drawn ticks',
      null),
  pageIndicator(
      'page-indicator',
      'Page Indicator',
      NativeComponentCategory.controls,
      'TabView(.page) + .indexViewStyle',
      'Next page'),
  checkbox(
      'checkbox',
      'Checkbox-Style Control',
      NativeComponentCategory.controls,
      'Custom ToggleStyle with SF Symbols',
      null),
  tabBar('tab-bar', 'Tab Bar', NativeComponentCategory.structure,
      'TabView + .tabItem', 'Next tab'),
  floatingTabBar(
      'floating-tab-bar',
      'Floating Tab Bar',
      NativeComponentCategory.structure,
      '.tabBarMinimizeBehavior(.onScrollDown) / custom capsule',
      null),
  tabBarItem('tab-bar-item', 'Tab Bar Item', NativeComponentCategory.structure,
      '.tabItem + .badge', null),
  expandableTabBar(
      'expandable-tab-bar',
      'Expandable Tab Bar',
      NativeComponentCategory.structure,
      'Glass capsules that expand with glassEffectID',
      null),
  searchTab('search-tab', 'Search Tab', NativeComponentCategory.structure,
      'Tab(role: .search) iOS 18+ / tabItem', null),
  sidebar('sidebar', 'Sidebar', NativeComponentCategory.structure,
      'NavigationSplitView + .listStyle(.sidebar)', null),
  navigationStack(
      'navigation-stack',
      'Navigation Stack',
      NativeComponentCategory.structure,
      'NavigationStack(path:) + navigationDestination',
      'Push level'),
  splitView('split-view', 'Split View', NativeComponentCategory.structure,
      'Three-column NavigationSplitView', null),
  floatingAccessory(
      'floating-accessory',
      'Floating Accessory View',
      NativeComponentCategory.structure,
      '.tabViewBottomAccessory (iOS 26) / safeAreaInset',
      null),
  inspector('inspector', 'Inspector Panel', NativeComponentCategory.structure,
      '.inspector(isPresented:)', 'Toggle inspector'),
  bottomSheet(
      'bottom-sheet',
      'Bottom Sheet',
      NativeComponentCategory.presentation,
      'Sheet with .height detent + background interaction',
      'Toggle sheet'),
  halfSheet(
      'half-sheet',
      'Half-Screen Sheet',
      NativeComponentCategory.presentation,
      '.presentationDetents([.medium])',
      'Present'),
  fullSheet('full-sheet', 'Full-Screen Sheet',
      NativeComponentCategory.presentation, '.fullScreenCover', 'Present'),
  detentedSheet(
      'detented-sheet',
      'Detented Sheet',
      NativeComponentCategory.presentation,
      'Detents with selection binding',
      'Present'),
  dragIndicator(
      'drag-indicator',
      'Sheet Drag Indicator',
      NativeComponentCategory.presentation,
      '.presentationDragIndicator',
      'Present'),
  alert('alert', 'Alert Dialog', NativeComponentCategory.presentation,
      '.alert with roles + text field', 'Show alert'),
  confirmationDialog(
      'confirmation-dialog',
      'Confirmation Dialog',
      NativeComponentCategory.presentation,
      '.confirmationDialog — popover on iOS 26',
      'Show dialog'),
  actionSheet(
      'action-sheet',
      'Action Sheet',
      NativeComponentCategory.presentation,
      'UIKit UIAlertController(.actionSheet)',
      'Show sheet'),
  popover('popover', 'Popover', NativeComponentCategory.presentation,
      '.popover + .presentationCompactAdaptation', 'Show popover'),
  toast(
      'toast',
      'Toast / Notification Overlay',
      NativeComponentCategory.presentation,
      'Glass capsule overlay with transition',
      'Show toast'),
  confirmationPopup(
      'confirmation-popup',
      'Confirmation Popup',
      NativeComponentCategory.presentation,
      'Custom glass card modal',
      'Show popup'),
  popupMenu('popup-menu', 'Popup Menu', NativeComponentCategory.menus,
      'Menu + Picker (pop-up button)', null),
  dropdownMenu('dropdown-menu', 'Dropdown Menu', NativeComponentCategory.menus,
      'Menu with sections, Picker and Toggle', null),
  contextMenu('context-menu', 'Context Menu', NativeComponentCategory.menus,
      '.contextMenu with preview', null),
  overflowMenu('overflow-menu', 'Overflow Menu', NativeComponentCategory.menus,
      'Toolbar Menu with ellipsis', null),
  nestedSubmenu('nested-submenu', 'Nested Submenu',
      NativeComponentCategory.menus, 'Menu inside Menu', null),
  shareMenu('share-menu', 'Share Menu', NativeComponentCategory.menus,
      'ShareLink + UIActivityViewController', 'Share'),
  textSelectionMenu('text-selection-menu', 'Text Selection Menu',
      NativeComponentCategory.menus, 'UITextView editMenuForTextIn', null),
  textField('text-field', 'Text Field', NativeComponentCategory.input,
      'TextField styles + glass field', null),
  secureField(
      'secure-field',
      'Secure Password Field',
      NativeComponentCategory.input,
      'SecureField with reveal + strength',
      null),
  searchField('search-field', 'Search Field', NativeComponentCategory.input,
      '.searchable + .searchSuggestions', null),
  textEditor('text-editor', 'Multiline Text Editor',
      NativeComponentCategory.input, 'TextEditor + FocusState', null),
  datePicker('date-picker', 'Date Picker', NativeComponentCategory.input,
      'DatePicker(.graphical / .compact)', null),
  timePicker('time-picker', 'Time Picker', NativeComponentCategory.input,
      'DatePicker(.hourAndMinute, .wheel)', null),
  wheelPicker('wheel-picker', 'Wheel Picker', NativeComponentCategory.input,
      'Picker(.wheel) multi-column', null),
  menuPicker('menu-picker', 'Menu Picker', NativeComponentCategory.input,
      'Picker(.menu)', null),
  colorPicker('color-picker', 'Color Picker', NativeComponentCategory.input,
      'ColorPicker (returns hex to Dart)', null),
  floatingSearchBar(
      'floating-search-bar',
      'Floating Search Bar',
      NativeComponentCategory.input,
      'Glass search capsule over content',
      'Focus search'),
  circularProgress(
      'circular-progress',
      'Circular Progress Indicator',
      NativeComponentCategory.progress,
      'Gauge(.accessoryCircularCapacity) + ring',
      'Restart'),
  linearProgress('linear-progress', 'Linear Progress Bar',
      NativeComponentCategory.progress, 'ProgressView(value:)', 'Restart'),
  determinateProgress(
      'determinate-progress',
      'Determinate Progress Bar',
      NativeComponentCategory.progress,
      'ProgressView(value:total:) + Gauge',
      'Next step'),
  indeterminateLoading(
      'indeterminate-loading',
      'Indeterminate Loading Indicator',
      NativeComponentCategory.progress,
      'ProgressView() + animated bar',
      null),
  downloadProgress(
      'download-progress',
      'Download Progress Indicator',
      NativeComponentCategory.progress,
      'App Store-style ring button',
      'Start / pause'),
  uploadProgress('upload-progress', 'Upload Progress Indicator',
      NativeComponentCategory.progress, 'Per-file ProgressView', 'Restart'),
  activityIndicator(
      'activity-indicator',
      'Activity Indicator',
      NativeComponentCategory.progress,
      'UIKit UIActivityIndicatorView',
      'Toggle'),
  galleryToolbar(
      'gallery-toolbar',
      'Gallery Toolbar',
      NativeComponentCategory.media,
      'Grid + bottomBar selection toolbar',
      null),
  photoViewerToolbar('photo-viewer-toolbar', 'Photo Viewer Toolbar',
      NativeComponentCategory.media, 'Glass top/bottom chrome', null),
  mediaControls('media-controls', 'Media Playback Controls',
      NativeComponentCategory.media, 'Now Playing glass card', 'Play / pause'),
  playPause('play-pause', 'Play / Pause Button', NativeComponentCategory.media,
      '.contentTransition(.symbolEffect(.replace))', 'Play / pause'),
  skipButtons(
      'skip-buttons',
      'Skip Forward / Backward Button',
      NativeComponentCategory.media,
      'gobackward.15 / goforward.30 + bounce',
      null),
  volumeSlider('volume-slider', 'Volume Slider', NativeComponentCategory.media,
      'Slider + MPVolumeView', null),
  mediaClose('media-close', 'Full-Screen Media Close Button',
      NativeComponentCategory.media, 'Glass xmark over media', null),
  pipControls(
      'pip-controls',
      'Picture-in-Picture Controls',
      NativeComponentCategory.media,
      'Draggable mini player + AVKit support check',
      'Toggle PiP'),
  cameraControls('camera-controls', 'Camera Controls',
      NativeComponentCategory.media, 'Shutter, modes, flash, flip', null),
  zoomControls('zoom-controls', 'Zoom Controls', NativeComponentCategory.media,
      'Zoom pills + MagnifyGesture', null),
  cropControls('crop-controls', 'Crop Controls', NativeComponentCategory.media,
      'Aspect ratios, straighten dial, rotate', null),
  scrollEdge(
      'scroll-edge',
      'Scroll-Edge Glass Effect',
      NativeComponentCategory.glass,
      '.scrollEdgeEffectStyle(.soft / .hard)',
      null),
  glassBackground('glass-background', 'Glass Background',
      NativeComponentCategory.glass, 'Glass.regular / .clear / .tint', null),
  customGlassShape('custom-glass-shape', 'Custom Glass Shape',
      NativeComponentCategory.glass, '.glassEffect(in: customShape)', null),
  glassButtonGroup('glass-button-group', 'Glass Button Group',
      NativeComponentCategory.glass, '.glassEffectUnion', null),
  glassContainer(
      'glass-container',
      'Glass Effect Container',
      NativeComponentCategory.glass,
      'GlassEffectContainer(spacing:) blending',
      null),
  glassMorphing('glass-morphing', 'Glass Morphing Animation',
      NativeComponentCategory.glass, '.glassEffectID morphing', 'Morph'),
  glassTransition(
      'glass-transition',
      'Glass Transition',
      NativeComponentCategory.glass,
      '.glassEffectTransition(.materialize)',
      'Show / hide'),
  appIcon(
      'app-icon',
      'App Icon with Layered Glass Styling',
      NativeComponentCategory.glass,
      'Layered icon: default / dark / clear / tinted',
      null),
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
