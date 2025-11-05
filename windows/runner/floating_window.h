#ifndef FLOATING_WINDOW_H_
#define FLOATING_WINDOW_H_

#include <windows.h>
#include <string>

class FloatingWindow {
 public:
  FloatingWindow();
  ~FloatingWindow();

  // Create and show the floating window
  bool Create(HWND parent_window, const std::string& stream_url, 
              const std::string& channel_name);
  
  // Show/hide the window
  void Show();
  void Hide();
  void Close();
  
  // Check if window exists
  bool IsVisible() const;
  
  // Get the window handle
  HWND GetHandle() const { return hwnd_; }

 private:
  static LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam);
  void RegisterWindowClass();
  
  HWND hwnd_;
  HWND parent_;
  std::string stream_url_;
  std::string channel_name_;
  static const wchar_t* kWindowClassName;
};

#endif  // FLOATING_WINDOW_H_
