//
//  ViewController.m
//  FMDBDemo
//
//  Created by 戴尼玛 on 16/3/27.
//  Copyright © 2016年 MIMO. All rights reserved.
//

#import "ViewController.h"
#import <FMDB.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *age;

@end

@implementation ViewController{
    FMDatabaseQueue *queue;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"testDB.db"];
    queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [queue inDatabase:^(FMDatabase *db) {
        if (![db open]) {
            NSLog(@"数据库打开失败");
            return;
        };
        if (![db executeUpdate:@"create table if not exists people (id integer primary key autoincrement, name text, phone text, age text);"]) {
            NSLog(@"创建表失败");
        }
    }];
}

- (IBAction)insert:(id)sender {
    [queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:[NSString stringWithFormat:@"insert into people (name, phone, age) values (\"%@\", \"%@\", \"%@\")",self.name.text,self.phone.text,self.age.text]]) {
            NSLog(@"插入失败");
        }
        [self setup];
    }];
}

- (IBAction)delete:(id)sender {
    [queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:[NSString stringWithFormat:@"delete from people where name = \"%@\"",self.name.text]]) {
            NSLog(@"删除失败");
        }
        [self setup];
    }];
}

- (IBAction)update:(id)sender {
    [queue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:[NSString stringWithFormat:@"update people set name = \"%@\", phone = \"%@\", age = \"%@\" where name = \"%@\"",self.name.text,self.phone.text,self.age.text,self.name.text]]) {
            NSLog(@"更新失败");
        }
        [self setup];
    }];
}

- (IBAction)select:(id)sender {
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from people where name = \"%@\"",self.name.text]];
        while (result.next) {
            NSString *name = [result stringForColumn:@"name"];
            NSString *phone = [result stringForColumn:@"phone"];
            NSString *age = [result stringForColumn:@"age"];
            self.name.text = name;
            self.phone.text = phone;
            self.age.text = age;
        }
    }];
}

-(void)setup{
    self.name.text = @"";
    self.phone.text = @"";
    self.age.text = @"";
}

@end
