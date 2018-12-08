sysmail_help_queue_sp @queue_type = 'Mail' ;


SELECT * FROM sysmail_event_log ORDER BY log_date DESC


SELECT * FROM sysmail_allitems ORDER BY send_request_date DESC


SELECT recipients, subject, body, send_request_date FROM sysmail_allitems WHERE Recipients = 'email@email.com' AND subject like '%Subject%' ORDER BY send_request_date DESC 
