---
title: PostgreSQL in Go
tags: Go
---

Over the summer I remade
[Brandreth Statistics](https://github.com/dgonyeo/brandreth2.0), a website for
viewing and searching entries from a guest book in a friend's cabin. It's an
http server written in Go that pulls entries from a Postgres database, dumps it
into html templates (that utilize [bootstrap](http://getbootstrap.com/)), and
serves it up for the user's enjoyment.

When I set out to learn how to use a postgres server in Go, I ended up
developing three functions that enabled me to easily and quickly add
functionality to the site. They rely on use of Go's [sql
package](http://golang.org/pkg/database/sql/), and the [lib/pq
package](https://github.com/lib/pq).

The first one simply opens a session with the database. It will either return
the last active database connection if it's still valid, open a new connection
if the last connection is no longer valid, or block until it can get a valid
connection (with 15 second retries).

```go
func (c *Controller) getSession() *sql.DB {
    if c.db == nil {
        log.Debug("opening connection")
        db, err := sql.Open("postgres", "postgres://username:password@host/database")
        if err != nil {
            log.Fatal("actuiring session: %v", err)
            time.Sleep(15 * time.Second)
            return c.getSession()
        }
        err = db.Ping()
        if err != nil {
            log.Fatal("pinging after acuiring session: %v", err)
            time.Sleep(15 * time.Second)
            return c.getSession()
        }
        c.db = db
        return c.db
    } else {
        err := c.db.Ping()
        if err != nil {
            log.Info("Unable to ping database connection, will attempt to make new connection")
            return c.getSession()
        }
        return c.db
    }
}
```

In this example, Controller is:

```go
type Controller struct {
    db *sql.DB
}
```

The second function is used when I have a select statement (or anything that
returns rows) to run. It uses the first function to get a database session. It
will run my statement, and return a `[]map[string]interface{}` containing my rows.

```go
func (c *Controller) getRows(queryString string, args ...interface{}) []map[string]interface{} {
    rows, err := c.getSession().Query(queryString, args...)
    defer rows.Close()

    if err != nil {
        log.Fatal("Querying rows: %v", err)
    }

    columns, _ := rows.Columns()
    count := len(columns)
    values := make([]interface{}, count)
    valuePtrs := make([]interface{}, count)
    var returnSlice []map[string]interface{}

    for rows.Next() {
        returnMap := make(map[string]interface{})
        for i, _ := range columns {
            valuePtrs[i] = &values[i]
        }

        rows.Scan(valuePtrs...)

        for i, col := range columns {
            var v interface{}
            val := values[i]
            b, ok := val.([]byte)
            if ok {
                v = string(b)
            } else {
                v = val
            }
            returnMap[col] = v
        }
        returnSlice = append(returnSlice, returnMap)
    }
    return returnSlice
}
```

The last function takes a row (a `map[string]interface{}`), and will fill in a
tagged struct with the rows. This is very useful for when I have a struct
type that represents the schema of a table. I can pull rows out of the database
with `getRows`, and use this function to turn the rows into a list of structs.

```go
func fillStruct(toFill interface{}, data map[string]interface{}) {
    ftd := make(map[string]reflect.Value)
    typeOf := reflect.TypeOf(toFill).Elem()
    valueOf := reflect.ValueOf(toFill)
    for i := 0; i < typeOf.NumField(); i++ {
        ftd[typeOf.Field(i).Tag.Get("sql")] = reflect.Indirect(valueOf).Field(i)
    }

    for key, val := range data {
        ftd[key].Set(reflect.ValueOf(val).Convert(ftd[key].Type()))
    }
}
```

This function relies on the [reflect package](http://golang.org/pkg/reflect/).
It will fill in all the fields in the array that have the `sql` tag by looking
for an equivalently named column in the row, and will cast the value in the row
to the type of the struct.

An example struct:

```go
type Entry struct {
    TripId     string    `sql:"trip_id"`
    UserId     string    `sql:"user_id"`
    TripReason string    `sql:"trip_reason"`
    DateStart  time.Time `sql:"date_start"`
    DateEnd    time.Time `sql:"date_end"`
    Entry      string    `sql:"entry"`
    Book       int       `sql:"book"`
}
```

With these I had everything I needed to make my site store and use data in
Postgres. If I was executing a random statement, I would get a connection with
`getSession`, if I wanted to fetch a specific value from something like an
aggregate function I'd use `getRows`, pull the data out of the
map[string]interface{} and cast it, and if I wanted to get a list of structs
representing all the rows I have for a specific query, I'd get the rows with
`getRows` and then feed the values into `fillStruct`. For more examples, check
out the [Github repo](https://github.com/dgonyeo/brandreth2.0).
