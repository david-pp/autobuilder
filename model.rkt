#lang racket

(provide get-qa-hosts
         get-build-history
         (struct-out buildhistory)
         (struct-out qahost))
         

(require db)

(struct buildhistory 
  (id
   buildtime
   status 
   revisions
   timeusage
   log) #:transparent)


(define (vector->buildhistory vec)
  (buildhistory
   (vector-ref vec 0)
   (vector-ref vec 1)
   (vector-ref vec 2)
   (vector-ref vec 3)
   (vector-ref vec 4)
   (vector-ref vec 5)))

(define (get-build-history)
  (map vector->buildhistory (hash-values (load-build-history))))


(struct qahost
  (name
   user
   ip
   status
   runing) #:transparent)

(define (vector->qahost vec)
  (qahost
   (vector-ref vec 0)
   (vector-ref vec 1)
   (vector-ref vec 2)
   (vector-ref vec 3)
   (vector-ref vec 4)))

(define (get-qa-hosts)
  (map vector->qahost (hash-values (load-qa-hosts))))

(define db-conn
  (virtual-connection
   (connection-pool
    (lambda ()
      (displayln "connection !")
      (mysql-connect #:server "127.0.0.1" 
                     #:user "david" 
                     #:password "123456"
                     #:database "david"))
    #:max-idle-connections 10)))

(define (drop-table table)
  (query-exec db-conn (string-append "drop table if exists " table)))

(define (init-db)
  (drop-table "build_history")
  (drop-table "qahosts")
  (query-exec db-conn 
              (string-append "create table build_history("
                             " id int unsigned not null auto_increment,"
                             " buildtime varchar(32) not null,"
                             " status int not null,"
                             " revisions varchar(255) not null default '',"
                             " timeusage int unsigned not null default 0,"
                             " log text,"
                             " primary key (id)"
                             ")"))
 
  (query-exec db-conn 
              (string-append "create table qahosts("
                             " name varchar(32) not null default '',"
                             " user varchar(32) not null default '',"
                             " ip varchar(32) not null default '',"
                             " status int not null default '0',"
                             " running int unsigned not null default '0',"
                             " log text,"
                             " primary key (name)"
                             ")")))

(define (prepare-test-data)
  (for ([i (build-list 10 values)])
    (query-exec db-conn 
                "insert into build_history(buildtime,status,revisions,timeusage,log) values(?, ?, ?, ?, ?)"
                "2015-02-03 19:00:00"  1 "1235|5678|90000" 12000 "测试下看看!!"))
  (for ([i (build-list 10 values)])
    (query-exec db-conn 
                "insert into qahosts(name,user,ip,running,log) values(?, ?, ?, ?, ?)"
                (string-append "QA" (number->string i)) 
                "david" 
                "127.0.0.1"
                1
                "test.....")))

(define (load-build-history)
  (rows->dict (query db-conn "select * from build_history")
              #:key "id"
              #:value '#("id" "buildtime" "status" "revisions" "timeusage" "log")))

(define (load-qa-hosts)
  (rows->dict (query db-conn "select * from qahosts")
              #:key "name"
              #:value '#("name" "user" "ip" "status" "running" "log")))

;(init-db)
;(prepare-test-data)