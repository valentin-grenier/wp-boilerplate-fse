import { useBlockProps } from "@wordpress/block-editor";

export default function save() {
	return (
		<p {...useBlockProps.save()}>
			{"Studio Blocks – hello from the saved content!"}
		</p>
	);
}
