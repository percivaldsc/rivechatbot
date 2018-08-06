package rivechatbot;

use strict;
use Plugins;
use Globals;
use Log qw(message warning error debug);
use Misc;
use Network;
use Network::Send;
use Network::Receive;
use RiveScript;

Plugins::register('rivechatbot', 'autoresponse bot', \&Unload);

my $rs = new RiveScript;
# Stream in some RiveScript code.
$rs->stream (q~
+ *
- ERR
~);
$rs->loadFile ("./replies.rive");
# Sort all the loaded replies.
$rs->sortReplies;

print "Hello World \n";

    my $hooks = Plugins::addHooks(
            ['packet/public_chat', \&onMessage, undef],
            ['packet/private_message', \&onMessage, undef],
            ['packet/system_chat', \&onMessage, undef],
            ['packet/guild_chat', \&onMessage, undef],
            ['packet/party_chat', \&onMessage, undef],
            ['AI_post', \&AI_post, undef]
    );

    sub onMessage {
        my ($packet, $args) = @_;
        my $prefix = "rivechat_";
        my $reply = "";
        #Don't answer, case it is the own message - taken from kadiliman
        my $msg = $args->{message};
        my ($chatMsgUser, $chatMsg);
                
        if ($msg =~/:/) {
                            ($chatMsgUser, $chatMsg) = $msg =~ /(.*?).:.(.*)/;
                    } else {
                            $chatMsg = $msg;
                    }
        return if ($chatMsgUser eq $char->{name});
        $args->{stage} = "start";
        $args->{chatmsg} = $chatMsg;
        if(index($chatMsg, "+") != -1){
                my ($n1, $n2) = split('\+',$chatMsg);
                $n1 =~ s/\D//g;
                $n2 =~ s/\D//g;
                $args->{reply} = $n1 + $n2;
                message "[RiveScript] $reply\n", "plugins";
        }
        elsif(index($chatMsg, "x") != -1){
                my ($n1, $n2) = split('x',$chatMsg);
                $n1 =~ s/\D//g;
                $n2 =~ s/\D//g;
                $args->{reply} = $n1 * $n2;
        }
        elsif(index($chatMsg, "-") != -1){
                my ($n1, $n2) = split('-',$chatMsg);
                $n1 =~ s/\D//g;
                $n2 =~ s/\D//g;
                $args->{reply} = $n1 - $n2;
        }
        else {
        $args->{reply} = $rs->reply ('localuser',$chatMsg);
        }
        $reply = $args->{reply};
        my @words = split /\s+/, $reply;
        my $average;
        foreach my $word (@words) {
                $average += length($word);
        }
        $average /= (scalar @words);
        my $typeSpeed = 80 * $average / 60;
        $args->{timeout} = (0.5 + rand(1)) + (length($reply) / $typeSpeed);
        $args->{time} = time;
        $args->{type} = "p";
        $args->{timeout} = (0.5 + rand(1)); 
        AI::queue("rivechat", $args);
    }

       sub AI_post {
                    my $args = AI::args;
                    my $chat = $args->{chatmsg};
                    my $answer = $args->{reply};
                    if ($args->{stage} eq 'end') {
                            AI::dequeue;
                    } elsif ($args->{stage} eq 'start') {
                            $args->{stage} = 'message' if (main::timeOut($args->{time}, $args->{timeout}));
                    } elsif ($args->{stage} eq 'message') {
                        if ( $answer ne 'ERR' ) {
                            sendMessage($messageSender, "c", $answer);    
                            message "[RiveScript] $answer\n", "plugins";
                            message "[RiveScript] $chat\n", "plugins";
                            }
                        $args->{stage} = 'end';
                    }

            }
