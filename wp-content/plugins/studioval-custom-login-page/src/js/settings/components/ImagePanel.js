import React, { useCallback } from "react";
import {
  Button,
  Card,
  CardHeader,
  CardBody,
  CardFooter,
  __experimentalHeading as Heading,
  __experimentalVStack as VStack,
  __experimentalHStack as HStack,
  __experimentalText as Text,
} from "@wordpress/components";
import { __ } from "@wordpress/i18n";

const RESET_KEYS = ["imageId", "imageUrl"];

function openMediaFrame(onSelect, currentId) {
  const frame = window.wp.media({
    title: __("Choose a background image", "studioval-clp"),
    button: { text: __("Use this image", "studioval-clp") },
    multiple: false,
    library: { type: "image" },
  });

  if (currentId) {
    frame.on("open", () => {
      const selection = frame.state().get("selection");
      const attachment = window.wp.media.attachment(currentId);
      attachment.fetch();
      selection.add(attachment);
    });
  }

  frame.on("select", () => {
    const attachment = frame.state().get("selection").first().toJSON();
    onSelect(attachment);
  });

  frame.open();
}

export default function ImagePanel({
  settings,
  onChange,
  onReset,
  hasImageLayout = false,
}) {
  const { imageId, imageUrl } = settings;

  const onSelect = useCallback(
    (media) => {
      onChange("imageId", media.id);
      onChange("imageUrl", media.url);
    },
    [onChange],
  );

  const onRemove = useCallback(() => {
    onChange("imageId", 0);
    onChange("imageUrl", "");
  }, [onChange]);

  const openFrame = useCallback(
    () => openMediaFrame(onSelect, imageId),
    [onSelect, imageId],
  );

  return (
    <Card size="small">
      <CardHeader>
        <Heading level={3} size={13}>
          {__("Background image", "studioval-clp")}
        </Heading>
      </CardHeader>
      <CardBody>
        <VStack spacing={3}>
          <Text variant="muted">
            {hasImageLayout
              ? __(
                  "Fills half of the screen. Recommended format: portrait, min 800 × 1000 px.",
                  "studioval-clp",
                )
              : __(
                  "Displayed as a full-page background. Recommended format: landscape, min 1920 × 1080 px.",
                  "studioval-clp",
                )}
          </Text>

          {imageUrl && (
            <div className="clp-image-preview">
              <img src={imageUrl} alt="" />
            </div>
          )}
          <HStack spacing={2} justify="flex-start">
            <Button variant="secondary" onClick={openFrame}>
              {imageUrl
                ? __("Replace", "studioval-clp")
                : __("Choose an image", "studioval-clp")}
            </Button>
            {imageUrl && (
              <Button variant="link" isDestructive onClick={onRemove}>
                {__("Remove", "studioval-clp")}
              </Button>
            )}
          </HStack>
        </VStack>
      </CardBody>
      <CardFooter>
        <Button variant="tertiary" onClick={() => onReset(RESET_KEYS)}>
          {__("Reset to default", "studioval-clp")}
        </Button>
      </CardFooter>
    </Card>
  );
}
