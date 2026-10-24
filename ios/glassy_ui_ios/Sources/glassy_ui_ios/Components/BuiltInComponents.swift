import SwiftUI

/// Every component shipped with the package, in catalog order.
/// Keep in sync with `NativeComponentType` in Dart.
enum BuiltInComponents {
  static let all: [any NativeComponent.Type] = [
    // Navigation & toolbars
    NavigationBarComponent.self, BackButtonComponent.self, CloseButtonComponent.self, NavigationTitleComponent.self,
    LargeNavigationTitleComponent.self, ToolbarComponent.self, FloatingToolbarComponent.self, BottomToolbarComponent.self,
    ToolbarActionButtonComponent.self,
    // Buttons
    GlassButtonComponent.self, ProminentGlassButtonComponent.self, ImageButtonComponent.self, CircularIconButtonComponent.self,
    SFSymbolsButtonComponent.self, PlusButtonComponent.self, MinusButtonComponent.self, FloatingActionButtonComponent.self,
    AvatarActionButtonComponent.self,
    // Controls
    SegmentedControlComponent.self, ToggleComponent.self, StepperComponent.self, SliderComponent.self,
    SliderTicksComponent.self, PageIndicatorComponent.self, CheckboxComponent.self,
    // Tabs & structure
    TabBarComponent.self, FloatingTabBarComponent.self, TabBarItemComponent.self, ExpandableTabBarComponent.self,
    SearchTabComponent.self, SidebarComponent.self, NavigationStackComponent.self, SplitViewComponent.self,
    FloatingAccessoryComponent.self, InspectorComponent.self,
    // Presentation
    BottomSheetComponent.self, HalfSheetComponent.self, FullSheetComponent.self, DetentedSheetComponent.self,
    DragIndicatorComponent.self, AlertComponent.self, ConfirmationDialogComponent.self, ActionSheetComponent.self,
    PopoverComponent.self, ToastComponent.self, ConfirmationPopupComponent.self,
    // Menus
    PopupMenuComponent.self, DropdownMenuComponent.self, ContextMenuComponent.self, OverflowMenuComponent.self,
    NestedSubmenuComponent.self, ShareMenuComponent.self, TextSelectionMenuComponent.self,
    // Input
    TextFieldComponent.self, SecureFieldComponent.self, SearchFieldComponent.self, TextEditorComponent.self,
    DatePickerComponent.self, TimePickerComponent.self, WheelPickerComponent.self, MenuPickerComponent.self,
    ColorPickerComponent.self, FloatingSearchBarComponent.self,
    // Progress
    CircularProgressComponent.self, LinearProgressComponent.self, DeterminateProgressComponent.self,
    IndeterminateLoadingComponent.self, DownloadProgressComponent.self, UploadProgressComponent.self,
    ActivityIndicatorComponent.self,
    // Media
    GalleryToolbarComponent.self, PhotoViewerToolbarComponent.self, MediaControlsComponent.self, PlayPauseComponent.self,
    SkipButtonsComponent.self, VolumeSliderComponent.self, MediaCloseComponent.self, PiPControlsComponent.self,
    CameraControlsComponent.self, ZoomControlsComponent.self, CropControlsComponent.self,
    // Liquid Glass
    ScrollEdgeComponent.self, GlassBackgroundComponent.self, CustomGlassShapeComponent.self, GlassButtonGroupComponent.self,
    GlassContainerComponent.self, GlassMorphingComponent.self, GlassTransitionComponent.self, AppIconComponent.self,
    WidgetAppearanceComponent.self,
  ]
}
