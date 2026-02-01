package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

var db *sql.DB

func main() {
	dsn := os.Getenv("MYSQL_DSN")
	if dsn == "" {
		dsn = "root:123456@tcp(mysql:3306)/counter"
	}
	var err error
	// 等待 MySQL 启动
	for i := 0; i < 10; i++ {
		db, err = sql.Open("mysql", dsn)
		if err == nil && db.Ping() == nil {
			break
		}
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatal("数据库连接失败:", err)
	}
	_, _ = db.Exec(`CREATE TABLE IF NOT EXISTS counter (id INT PRIMARY KEY, value INT)`)
	_, _ = db.Exec(`INSERT IGNORE INTO counter (id, value) VALUES (1, 0)`)

	http.HandleFunc("/count", countHandler)
	fmt.Println("Server running on :3000")
	log.Fatal(http.ListenAndServe(":3000", nil))
}

func countHandler(w http.ResponseWriter, r *http.Request) {
	_, _ = db.Exec(`UPDATE counter SET value = value + 1 WHERE id = 1`)
	var value int
	_ = db.QueryRow(`SELECT value FROM counter WHERE id = 1`).Scan(&value)
	fmt.Fprintf(w, "Count: %d", value)
}