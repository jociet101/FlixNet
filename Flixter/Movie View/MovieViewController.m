//
//  MovieViewController.m
//  Flixter
//
//  Created by Jocelyn Tseng on 6/15/22.
//

#import "MovieViewController.h"
#import "MovieTableViewCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
        
    UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] init];
    self.activityIndicator = ai;
    self.activityIndicator.center = self.tableView.center;
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
    
    [self fetchData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

}

- (void)fetchData {
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=afce5775823482bce9ebe26ae2a18553"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               NSString* errorName = [NSString stringWithFormat:@"%@", [error localizedDescription]];
               [self handleAlert:errorName];
           }
           else {
               
               [self.activityIndicator stopAnimating];
               
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
//                   NSLog(@"%@", dataDictionary);
               
               // Get array of movies and store into property
               self.movies = dataDictionary[@"results"];
               
               // reload your table view data
               [self.tableView reloadData];
           }
        
        [self.refreshControl endRefreshing];
            
       }];
    [task resume];
}

- (void)handleAlert:(NSString *)errorName {
    [self.activityIndicator stopAnimating];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to Display Movies" message:errorName preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self viewDidLoad];
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated: YES completion: nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
     
    cell.titleLabel.text = self.movies[indexPath.row][@"title"];
    cell.synopsisLabel.text = self.movies[indexPath.row][@"overview"];
    
    NSString *baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString *tailURL = self.movies[indexPath.row][@"poster_path"];
    
    NSString *imagePath = [baseURL stringByAppendingString:tailURL];
    NSURL *posterURL = [NSURL URLWithString:imagePath];
        
    [cell.posterImage setImageWithURL:posterURL];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//
//    if (searchText.length != 0) {
//
//        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
//            return [evaluatedObject containsString:searchText];
//        }];
//        self.filteredData = [self.data filteredArrayUsingPredicate:predicate];
//
//        NSLog(@"%@", self.filteredData);
//
//    }
//    else {
//        self.filteredData = self.data;
//    }
//
//    [self.tableView reloadData];
//
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MovieTableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *data = self.movies[indexPath.row];
    DetailsViewController *detailVC = [segue destinationViewController];
    detailVC.incomingData = data;
}

@end