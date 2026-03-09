-- +goose Up
CREATE TABLE public.devices (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	user_id uuid NOT NULL,
	device_uid varchar(255) NOT NULL,
	device_type varchar(20) NULL,
	model_name varchar(100) NULL,
	os_version varchar(50) NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT devices_device_uid_key UNIQUE (device_uid),
	CONSTRAINT devices_pkey PRIMARY KEY (id)
);

CREATE TRIGGER update_devices_modtime
	BEFORE UPDATE ON public.devices
	FOR EACH ROW EXECUTE FUNCTION update_timestamp();

ALTER TABLE public.devices ADD CONSTRAINT fk_user_devices FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

-- +goose Down
DROP TRIGGER IF EXISTS update_devices_modtime ON public.devices;
DROP TABLE IF EXISTS public.devices;