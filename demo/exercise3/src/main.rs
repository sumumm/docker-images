use chrono::Local;

fn main() {
    // 获取当前时间
    let now = Local::now();
    let timestamp = now.format("%Y-%m-%d %H:%M:%S").to_string();
    
    // 直接输出到 stdout
    println!("Hello from Rust!");
    println!("当前时间: {}", timestamp);
}