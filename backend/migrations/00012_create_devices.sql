-- public.devices definition

-- Drop table

-- DROP TABLE public.devices;

CREATE TABLE public.devices (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	user_id uuid NOT NULL,
	device_uid varchar(255) NOT NULL,
	device_type varchar(20) NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT devices_device_uid_key UNIQUE (device_uid),
	CONSTRAINT devices_pkey PRIMARY KEY (id)
);

-- Table Triggers

create trigger update_devices_modtime before
update
    on
    public.devices for each row execute function update_timestamp();


-- public.devices foreign keys

ALTER TABLE public.devices ADD CONSTRAINT fk_user_devices FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;