#include "floating_window.h"
#include <flutter/standard_method_codec.h>

const wchar_t* FloatingWindow::kWindowClassName = L"IPTVCasperFloatingWindow";

FloatingWindow::FloatingWindow() : hwnd_(nullptr), parent_(nullptr) {}

FloatingWindow::~FloatingWindow() {
  Close();
}

void FloatingWindow::RegisterWindowClass() {
  WNDCLASSW wc = {};
  wc.lpfnWndProc = WindowProc;
  wc.hInstance = GetModuleHandle(nullptr);
  wc.lpszClassName = kWindowClassName;
  wc.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
  wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
  RegisterClassW(&wc);
}

bool FloatingWindow::Create(HWND parent_window, const std::string& stream_url,
                             const std::string& channel_name) {
  parent_ = parent_window;
  stream_url_ = stream_url;
  channel_name_ = channel_name;

  RegisterWindowClass();

  // Create a floating, always-on-top window
  hwnd_ = CreateWindowExW(
      WS_EX_TOPMOST | WS_EX_LAYERED | WS_EX_TOOLWINDOW,  // Always on top, transparent, no taskbar
      kWindowClassName,
      L"IPTV Player",
      WS_POPUP | WS_VISIBLE | WS_SYSMENU | WS_THICKFRAME,  // Popup window with resize
      100, 100,  // Initial position
      600, 360,  // Initial size (16:9)
      nullptr,   // No parent (independent window)
      nullptr,
      GetModuleHandle(nullptr),
      this);

  if (!hwnd_) {
    return false;
  }

  // Set window transparency
  SetLayeredWindowAttributes(hwnd_, 0, 255, LWA_ALPHA);
  
  // Ensure it's always on top
  SetWindowPos(hwnd_, HWND_TOPMOST, 0, 0, 0, 0, 
               SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);

  return true;
}

void FloatingWindow::Show() {
  if (hwnd_) {
    ShowWindow(hwnd_, SW_SHOW);
    SetWindowPos(hwnd_, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
  }
}

void FloatingWindow::Hide() {
  if (hwnd_) {
    ShowWindow(hwnd_, SW_HIDE);
  }
}

void FloatingWindow::Close() {
  if (hwnd_) {
    DestroyWindow(hwnd_);
    hwnd_ = nullptr;
  }
}

bool FloatingWindow::IsVisible() const {
  return hwnd_ && IsWindowVisible(hwnd_);
}

LRESULT CALLBACK FloatingWindow::WindowProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
  FloatingWindow* window = nullptr;

  if (msg == WM_CREATE) {
    auto create_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    window = static_cast<FloatingWindow*>(create_struct->lpCreateParams);
    SetWindowLongPtr(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(window));
  } else {
    window = reinterpret_cast<FloatingWindow*>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
  }

  switch (msg) {
    case WM_CLOSE:
      if (window) {
        window->Close();
      }
      return 0;

    case WM_DESTROY:
      PostQuitMessage(0);
      return 0;

    case WM_PAINT: {
      PAINTSTRUCT ps;
      HDC hdc = BeginPaint(hwnd, &ps);
      
      // Draw black background
      RECT rect;
      GetClientRect(hwnd, &rect);
      FillRect(hdc, &rect, (HBRUSH)GetStockObject(BLACK_BRUSH));
      
      // Draw text indicating this is the floating player
      SetTextColor(hdc, RGB(255, 255, 255));
      SetBkMode(hdc, TRANSPARENT);
      const char* text = "IPTV Floating Player\n\nVideo playback will be integrated here";
      DrawTextA(hdc, text, -1, &rect, DT_CENTER | DT_VCENTER | DT_WORDBREAK);
      
      EndPaint(hwnd, &ps);
      return 0;
    }

    case WM_NCHITTEST: {
      // Allow dragging the window by any part of its client area
      LRESULT hit = DefWindowProc(hwnd, msg, wparam, lparam);
      if (hit == HTCLIENT) {
        return HTCAPTION;  // Make entire window draggable
      }
      return hit;
    }
  }

  return DefWindowProc(hwnd, msg, wparam, lparam);
}
