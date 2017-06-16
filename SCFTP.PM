package SCFTP;
require exporter;

my @ISA =qw(Export);

my @EXPORT=qw(getFTPlist);

our $VERSION =1.00;


use strict;
use Cwd;
use File::Copy;
use File::Basename;
use Data::Dumper;
use Config::IniFiles;
use Net::FTP;
 


sub new {
my $class = shift();
print("CLASS = $class\n");
my $self = {};
$self->{FTPID}=shift ();
$self->{FTPAddress} = shift();
$self->{FTPUsername} = shift();
$self->{FTPPassword} = shift();
bless $self, $class;
return $self; 
}

sub connect2ftp
{
     my ($self) = @_;
     $self->{ftpinstant}=Net::FTP->new($self->{FTPAddress});
     
     if ( $self->{ftpinstant} == undef) {
        return 0;
     }
     else
     {
        $self->{ftpinstant}->login($self->{FTPUsername},$self->{FTPPassword});
        if($@)
        {
        	print "login ftp failed:$@ \n";
        	return 0;
        }
        else
        {
        	return 1;
        }
     }  
}

sub GetFTPID
{
    
     my ($self) = @_;
     return $self->{FTPID};
}
sub uploadfile
{
     my ($self) = shift @_;
     my $dir=shift @_;
     my $file=shift @_;
     my $curdir=getcwd();
     if ( $self->{ftpinstant} == undef) {
        return 0;
     } 
     $self->{ftpinstant}->cwd(); 
     $self->{ftpinstant}->binary; 
     chdir $dir; 
     $self->{ftpinstant}->put($file,$file); 
     chdir $curdir;
     
}

sub downloadfile                              #add by victor for download files
{
	my ($self) = shift @_;
     my $dir=shift @_;
     my $file=shift @_;
     my $curdir=getcwd();
     if ( $self->{ftpinstant} == undef) {
        return 0;
     } 
     $self->{ftpinstant}->cwd(); 
     $self->{ftpinstant}->binary; 
     chdir $dir; 
     $self->{ftpinstant}->get($file,$file); 
     chdir $curdir;
	
	
	}
	
	
	
sub closeftp
{
     my ($self) = @_; 
     if ( $self->{ftpinstant} == undef) {
        return 0;
     }
    $self->{ftpinstant}->quit;
}