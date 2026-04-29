import React, { useCallback } from "react";
import {
  TextControl,
  SelectControl,
  Button,
  Card,
  CardHeader,
  CardBody,
  CardDivider,
  CardFooter,
  Notice,
  __experimentalHeading as Heading,
  __experimentalVStack as VStack,
  __experimentalHStack as HStack,
  __experimentalText as Text,
} from "@wordpress/components";
import { __ } from "@wordpress/i18n";

const RESET_KEYS = [
  "logoId",
  "logoUrl",
  "logoSource",
  "customTitle",
  "titleSource",
];

const siteIconUrl = window.studiovalClpData?.siteIconUrl ?? "";
const siteTitle = window.studiovalClpData?.siteTitle ?? "";
const siteTagline = window.studiovalClpData?.siteTagline ?? "";

function openLogoFrame(onSelect, currentId) {
  const frame = window.wp.media({
    title: __("Choose a logo", "studioval-clp"),
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

export default function BrandingPanel({ settings, onChange, onReset }) {
  const {
    logoId,
    logoUrl,
    logoSource = "custom",
    customTitle,
    titleSource = "custom",
  } = settings;

  const onSelectLogo = useCallback(
    (media) => {
      onChange("logoId", media.id);
      onChange("logoUrl", media.url);
    },
    [onChange],
  );

  const onRemoveLogo = useCallback(() => {
    onChange("logoId", 0);
    onChange("logoUrl", "");
  }, [onChange]);

  const openFrame = useCallback(
    () => openLogoFrame(onSelectLogo, logoId),
    [onSelectLogo, logoId],
  );

  const isCustomTitle = "custom" === titleSource;
  const isCustomLogo = "custom" === logoSource;

  return (
    <Card size="small">
      <CardHeader>
        <Heading level={3} size={13}>
          {__("Branding", "studioval-clp")}
        </Heading>
      </CardHeader>
      <CardBody>
        <VStack spacing={3}>
          <SelectControl
            label={__("Title source", "studioval-clp")}
            value={titleSource}
            options={[
              { label: __("Custom text", "studioval-clp"), value: "custom" },
              { label: __("Site title", "studioval-clp"), value: "site" },
            ]}
            onChange={(val) => onChange("titleSource", val)}
            help={__(
              "Choose where the title displayed above the form comes from.",
              "studioval-clp",
            )}
            __nextHasNoMarginBottom
          />

          {isCustomTitle ? (
            <TextControl
              label={__("Page title", "studioval-clp")}
              help={__(
                "Replaces the site name displayed above the form.",
                "studioval-clp",
              )}
              value={customTitle}
              onChange={(val) => onChange("customTitle", val)}
              placeholder={__("My Site", "studioval-clp")}
              __nextHasNoMarginBottom
            />
          ) : (
            <VStack spacing={1}>
              <Text>
                {siteTitle || __("(site title is empty)", "studioval-clp")}
              </Text>
              {siteTagline && <Text variant="muted">{siteTagline}</Text>}
            </VStack>
          )}
        </VStack>
      </CardBody>

      <CardDivider />

      <CardBody>
        <VStack spacing={3}>
          <VStack spacing={1}>
            <Heading level={4} size={11}>
              {__("Logo", "studioval-clp")}
            </Heading>
            <Text variant="muted">
              {__("Replaces the default WordPress logo.", "studioval-clp")}
            </Text>
          </VStack>

          <SelectControl
            label={__("Logo source", "studioval-clp")}
            value={logoSource}
            options={[
              { label: __("Custom logo", "studioval-clp"), value: "custom" },
              { label: __("Site icon", "studioval-clp"), value: "site-icon" },
            ]}
            onChange={(val) => onChange("logoSource", val)}
            __nextHasNoMarginBottom
          />

          {isCustomLogo ? (
            <VStack spacing={3}>
              {logoUrl && (
                <div className="clp-logo-preview">
                  <img src={logoUrl} alt="" />
                </div>
              )}
              <HStack spacing={2} justify="flex-start">
                <Button variant="secondary" onClick={openFrame}>
                  {logoUrl
                    ? __("Replace", "studioval-clp")
                    : __("Choose a logo", "studioval-clp")}
                </Button>
                {logoUrl && (
                  <Button variant="link" isDestructive onClick={onRemoveLogo}>
                    {__("Remove", "studioval-clp")}
                  </Button>
                )}
              </HStack>
            </VStack>
          ) : siteIconUrl ? (
            <div className="clp-logo-preview">
              <img src={siteIconUrl} alt="" />
            </div>
          ) : (
            <Notice status="warning" isDismissible={false}>
              {__(
                "No site icon is configured. Set one under Settings → General → Site Icon.",
                "studioval-clp",
              )}
            </Notice>
          )}
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
