package SCDB;
require exporter;

my @ISA =qw(Export);

my @EXPORT=qw(getLeaderList);

our $VERSION =1.00;


use strict;  
use Cwd;
use File::Copy; 
use File::Basename; 
use Data::Dumper;
use Config::IniFiles;
use SCFTP;
use DBI; 
 


sub new {
my $class = shift();
print("CLASS = $class\n");
my $self = {}; 
$self->{DBAddress} = shift();
$self->{DBName} = shift();
$self->{DBUsername} = shift();
$self->{DBPassword} = shift();
bless $self, $class;
return $self; 
}

sub connect2db
{
    my ($self) = @_;
    $self->{dbinstant}=DBI->connect("DBI:mysql:database=$self->{DBName};host=$self->{DBAddress}","$self->{DBUsername}","$self->{DBPassword}",{'RaiseError'=>1})|| return 0;
    return 1;
}

sub disconnect2db
{
    my ($self) = @_;
    $self->{dbinstant}->disconnect();
    return 1;
}

sub reconnect2db
{
   disconnect2db;     #add by victor
	 connect2db;
}

sub GetSha1List
{
   	my ($self)=@_;
   	#my @GetSha1;
   	my $GetSha1;
   	my $sql=$self->{dbinstant}->prepare("select sha1 from sampleinfo where (Type=1 or Type=2) and isMalicious='1' and isexport='0' and ftpserver='$_[1]' limit 1"); 
	  $sql->execute();
	  while(my $row_ref = $sql->fetchrow_arrayref) {                           #add by victor;
    #print  "$row_ref->[0]\n";
    $GetSha1=$row_ref->[0];
    #push @GetSha1,$row_ref->[1];
    }
    return $GetSha1;
}

sub SetIsExport
{
    my ($self)=@_;    #
    my $sql=$self->{dbinstant}->prepare(" update sampleinfo set sampleinfo.isexport='1' where sha1='$_[1]'");	  #add by victor;
	  $sql->execute();
		
}

sub getDDaActRegList
{
    my ($self) = @_; 
    my %DDaActtypehash;     
    my $sql=$self->{dbinstant}->prepare("select  RegularExpre, ActionName from ddaaction");
    $sql->execute();
    while(my $row_ref = $sql->fetchrow_arrayref) {
    print  "$row_ref->[0]\t$row_ref->[1]\n";
    $DDaActtypehash{$row_ref->[1]}=$row_ref->[0];
    }
    return %DDaActtypehash;    
    
}


sub getDDaActList
{
    my ($self) = @_; 
    my %DDaActtypehash;     
    my $sql=$self->{dbinstant}->prepare("select  isInValid, ActionName from ddaaction");
    $sql->execute();
    while(my $row_ref = $sql->fetchrow_arrayref) {
    print  "$row_ref->[0]\t$row_ref->[1]\n";
    $DDaActtypehash{$row_ref->[1]}=$row_ref->[0];
    }
    return %DDaActtypehash;
    
    
}

sub getActionList
{
    my ($self) = @_; 
    my %actiontypehash;     
    my $sql=$self->{dbinstant}->prepare("select  id, ActionName from actiontype");
    $sql->execute();
    while(my $row_ref = $sql->fetchrow_arrayref) {
    print  "$row_ref->[0]\t$row_ref->[1]\n";
    $actiontypehash{$row_ref->[1]}=$row_ref->[0];
    }
    return %actiontypehash;
    
    
}

sub getLeaderList
{
    my ($self) = @_; 
    my %leadertypehash;     
    my $sql=$self->{dbinstant}->prepare("select  id, LeaderName from leadertable");
    $sql->execute();
    while(my $row_ref = $sql->fetchrow_arrayref) {
    print  "$row_ref->[0]\t$row_ref->[1]\n";
    $leadertypehash{$row_ref->[1]}=$row_ref->[0];
    }
    return %leadertypehash;
}
sub AddLeaderType
{
    my ($self) = shift;
    my $LeaderName=shift; 
    my $sql=$self->{dbinstant}->prepare("insert into leadertable(LeaderName ,FileName) values('$LeaderName','')");
    $sql->execute();
		
    $sql=$self->{dbinstant}->prepare("select id from leadertable where LeaderName= '$LeaderName' ");
    $sql->execute();
    my @array = $sql->fetchrow_array;
    my $returnVal=$array[0];
    return $returnVal;
     
}
sub AddActionType
{
    my ($self) = shift;
    my $ActionName=shift; 
    my $sql=$self->{dbinstant}->prepare("insert into actiontype(ActionName) values('$ActionName')");
    $sql->execute();
		
    $sql=$self->{dbinstant}->prepare("select id from actiontype where ActionName= '$ActionName' ");
    $sql->execute();
    my @array = $sql->fetchrow_array;
    my $returnVal=$array[0];
    return $returnVal;
    
    
}


sub AddDDaActReg
{
    my ($self) = shift;
    my $ActionName=shift; 
    print "new ActionName :$ActionName\n";
    my $sql=$self->{dbinstant}->prepare("insert into ddaaction(ActionName,MaxCount,isInValid,RegularExpre) values('$ActionName',0,0,'')");
    $sql->execute();
		
    $sql=$self->{dbinstant}->prepare("select id from actiontype where ActionName= '$ActionName' ");
    $sql->execute();
    my @array = $sql->fetchrow_array;
    my $returnVal=$array[0];
    return $returnVal;
    
    
}

sub InsertddaReport
{
    
    my ($self) = shift;
    my $SampleID = shift;
    my $Action = shift;
    my $Detail = shift;
    
    my $sql=$self->{dbinstant}->prepare("insert ignore into ddareport(SampleID,Action,Detail) values('$SampleID','$Action','$Detail')");
    $sql->execute();
    my $last_id=$self->{dbinstant}->{'mysql_insertid'};
    return $last_id;
    
    
}
sub GetSampleID
{
    my ($self) = shift;
    my $filesha1 = shift; 
    my $returnVal;
    my $sql=$self->{dbinstant}->prepare("select id from sampleinfo where sha1= '$filesha1' ");
    $sql->execute();
    my @array = $sql->fetchrow_array;
    if($#array < 0)
    {
    	$returnVal= 0;
    }
    else
    {
    	$returnVal=$array[0];
    }
    return $returnVal;
} 
sub InsertSampleInfo
{
    my ($self) = shift;
    my $filesha1 = shift;
    my $sourceid=shift;
    
    #my $sql=$self->{dbinstant}->prepare("replace into sampleinfo(sha1,sourceid) values('$filesha1','$sourceid')");
    my $sql=$self->{dbinstant}->prepare("insert into sampleinfo(sha1,sourceid) values('$filesha1','$sourceid') on duplicate key update sourceid=$sourceid");
    $sql->execute();
    my $last_id=$self->{dbinstant}->{'mysql_insertid'};
    return $last_id;
    
}
sub InsertRpf2Source
{    
    my ($self) = shift;
    my $Detection = shift;
    my $Actionid=shift;
    my $Flg=shift;
    my $crc0=shift;
    my $crc1=shift;
    my $crc2=shift;
    my $othercrc=shift;
    my $LeaderType=shift;
    my $SourceStates=shift;
    my $crcCount=shift;
    
    my $sql=$self->{dbinstant}->prepare("insert ignore into rpf2source(Detection,ActionID,Flag,crc0,crc1,crc2,otherCRC,LeaderType,SourceStates,crcCount,CreateTime,LastTime) values('$Detection','$Actionid','$Flg','$crc0','$crc1','$crc2','$othercrc','$LeaderType','$SourceStates','$crcCount',now(),now())");
    eval {$sql->execute()};
    if($@){
    	print "An error occured: $@"; #add by Victor
    	}
    my $last_id=$self->{dbinstant}->{'mysql_insertid'};
     return $last_id;
    
}
sub SampleLocation
{
    my ($self)=shift;
    my $sha1=shift;
    my $ftp=shift;
    
    my $sql=$self->{dbinstant}->prepare("update sampleinfo set ftpserver=$ftp where sha1=\'$sha1\';");
    $sql->execute();
    return 1;
}
sub SampleisMalicious
{
    my ($self)=shift;
    my $sha1=shift;
    my $isMalicious=shift;
    
    my $sql=$self->{dbinstant}->prepare("update sampleinfo set isMalicious=$isMalicious where sha1=\'$sha1\';");
    $sql->execute();
    return 1;
    
}

sub GetFtpDB
{    
    my ($self)=shift; 
    
    
    my @ftparray;     
    my $sql=$self->{dbinstant}->prepare("select id, ip, user ,psw from ftpserver where enable = 1;");
    $sql->execute();
    while(my $row_ref = $sql->fetchrow_arrayref) {
    print  "$row_ref->[0]\t===$row_ref->[1]==$row_ref->[2]=$row_ref->[3]\n";
    my  $tmp= SCFTP->new($row_ref->[0],$row_ref->[1],$row_ref->[2],$row_ref->[3]);
    
    push(@ftparray,$tmp);
    }
    return @ftparray;
    
    
}
return 1;

sub GetFtpDBO
{    
    my ($self)=shift; 
    
    
    my @ftparray;     
    my $sql=$self->{dbinstant}->prepare("select id, ip, user ,psw from ftpserver where enable = 0;");
    $sql->execute();
    while(my $row_ref = $sql->fetchrow_arrayref) {
    print  "$row_ref->[0]\t===$row_ref->[1]==$row_ref->[2]=$row_ref->[3]\n";
    my  $tmp= SCFTP->new($row_ref->[0],$row_ref->[1],$row_ref->[2],$row_ref->[3]);
    
    push(@ftparray,$tmp);
    }
    return @ftparray;
    
    
}
return 1;