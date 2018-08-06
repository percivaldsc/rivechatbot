package rivechatbot;

use strict;
use Plugins;
use Globals;
use Log qw(message warning error debug);
use Misc;
use Network;
use Network::Send;
use Network::Receive;

Plugins::register('rivechatbot', 'autoresponse bot', \&Unload);

print "Hello Wolrd \n";

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
        AI::queue("rivechat", $args);
    }

       sub AI_post {
                    my $args = AI::args;
                    my $chat = $args->{chatmsg};
                    if ($args->{stage} eq 'end') {
                            AI::dequeue;
                    } elsif ($args->{stage} eq 'start') {
                            message "[RiveScript] $chat\n", "plugins";
                             $args->{stage} = 'end';
                    }
            }
